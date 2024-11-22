# K8S Administration v1.27

## Baseline set up
For each node do :

### Hostname

Set hostname of the different server parts constituting a cluster.
```
sudo hostnamectl set-hostname <your server identifier name >
```
Configure mapping to simplify communications between servers
```
sudo vim /etc/hosts
```
All entries need to be correctly mapped and copy on each part of the cluster

### Kernel configuration
Configure Linux kernel modules required to run containerd, a platform used to manage containers. These modules (overlay and br_netfilter) are essential for containerd (and Docker, if used) to function properly. They allow to efficiently manage the containers' file systems and configure the networks needed for their communication.
```
cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
> overlay
> br_netfilter
> EOF
```
Load Linux kernel modules into the system
```
sudo modprobe overlay
sudo modprobe br_netfilter
```
**OverlayFS** is a stacked file system that allows multiple file systems to be layered on top of each other. It is particularly used in containers (like Docker and containerd) to efficiently manage image layers.

**br_netfilter** module is crucial in container environments that use network bridges, such as Kubernetes or Docker. It ensures that network packet management tools, such as iptables, can properly handle network traffic between containers or between a container and the outside world.

The following command configures some Linux kernel networking settings required for Kubernetes and its container runtime (CRI)
```
cat << EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
> net.bridge.bridge-nf-call-iptables  = 1
> net.bridge.bridge-nf-call-ip6tables = 1
> net.ipv4.ip_forward                 = 1
> EOF
```
Then apply the system settings defined in the configuration files (located in /etc/sysctl.conf and /etc/sysctl.d/)
```
sudo sysctl --system
```
### containerd setup
Update and install containerd
```
sudo apt-get update && sudo apt-get install -y containerd
```
Then configure containerd, the container runtime, by generating a default configuration file and registering it in the system. Finally restart the service.
```
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
```
Kubernetes requires swap to be disabled on cluster nodes because the container management system expects to manage memory directly without swap intervention.  
*The command disables swap until the next reboot. If you reboot, the swap spaces defined in /etc/fstab will be re-enabled automatically.*
```
sudo swapoff -a
```

### Installation of kubelet, kubeadm and kubectl
Install libs to download and manage files via secure protocols (HTTPS)
```
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
```
The following command adds a GNU Privacy Guard (GPG) key to authenticate packages downloaded from a third-party APT repository, in this case Google Cloud's
```
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
```
The following command adds the official Kubernetes repository to your Ubuntu system's APT sources list to enable installation and updating of Kubernetes components like kubectl, kubeadm, and kubelet
```
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
> deb https://apt.kubernetes.io/ kubernetes-xenial main
>EOF
```
Then update and install kubelet, kubeadm, kubectl
```
sudo apt-get update
sudo apt-get install -y kubelet=1.27.0-00 kubeadm=1.27.0-00 kubectl=1.27.0-00
```
The following command prevents APT from automatically updating the specified packages (in this case, kubelet, kubeadm, and kubectl):
```
sudo apt-mark hold kubelet kubeadm kubectl
```

End of the baseline setup for each node of K8S cluster

## Control plane
Go on the control plane node.  
1. ```sudo kubeadm init``` :
Starts the Kubernetes cluster initialization process by configuring the current node as the master node (control plane). Generates necessary certificates, initializes the API, scheduler, controller, and key/value store (etcd).
2. ```--pod-network-cidr=192.168.0.0/16``` :
Specifies the IP address range used by the pod network in the cluster. This option is essential for configuring pod networking solutions like Calico, Flannel, or Weave. The CIDR here, 192.168.0.0/16, is a common choice that is compatible with most network configurations. 
3. ```--kubernetes-version=1.27.0``` :
Forces installation of the specified Kubernetes version to avoid incompatibilities between the master node and other components.
```
sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.27.0
```
Copy and past :
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

To see nodes status
```
kubectl get nodes
```
Configure networking to let the control plan be ready
```
kubectl apply -f https:// docs.projectcalico.org/manifests/calico.yaml
```
## Worker nodes
Now to join the other nodes (workers) to the cluster :
```
kubeadm token create --print-join-command
```
The copy the output command and paste it on the others worker nodes

Finally test the installation by running :
```
kubectl get nodes
```