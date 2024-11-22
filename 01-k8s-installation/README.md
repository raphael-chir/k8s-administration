# K8S Administration v1.29

## Baseline set up
**For each nodes do :**

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
overlay
br_netfilter
EOF
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
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
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
```
Set the cgroup driver for containerd to systemd which is required for kubelet
```
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml            
```
Verify 
```
sudo grep 'SystemdCgroup = true' /etc/containerd/config.toml
```
Restart containerd with the new configuration
```
sudo systemctl restart containerd
```
Kubernetes requires swap to be disabled on cluster nodes because the container management system expects to manage memory directly without swap intervention.  
```
sudo swapoff -a
```
*The command disables swap until the next reboot. If you reboot, the swap spaces defined in /etc/fstab will be re-enabled automatically.*
```
sudo vi /etc/fstab
```

### Installation of kubelet, kubeadm and kubectl
Install libs to download and manage files via secure protocols (HTTPS)
```
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```
Add k8s.io's apt repository gpg key, warn for k8s version
```
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```
Add the kubernetes apt repository
```
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
Update the package list and inspect available versions with apt-cache
```
sudo apt-get update
sudo apt-cache policy kubelet | head -n 20
```

Then install specific version of kubelet, kubeadm, kubectl
```
VERSION=1.29.1-1-1
sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
```
The following command prevents APT from automatically updating the specified packages (in this case, kubelet, kubeadm, and kubectl):
```
sudo apt-mark hold kubelet kubeadm kubectl containerd
```

Verify systemd Units  
Note that kubelet is in dead status until a cluster is created or a node is joined to an existing cluster
```
sudo systemctl status kubelet.service
sudo systemctl status containerd.service
```

End of the baseline setup for each node of K8S cluster

## Control plane

![alt text](img/00-kubadm-bootstrap.png)
Go on the control plane node.  
First we download calico manifest and check the network pod range (CALICO_IPV4POOL_CIDR)
```
wget https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml
vi calico.yaml
```
Bootstrap the cluster
```
sudo kubeadm init --kubernetes-version 1.29.1
```
![alt text](img/01-kubeadm-init.png)

Copy and past :
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Start calico pod, the pod network 
```
kubectl apply -f calico.yaml
```
See all the pods status 
```
kubectl get pods --all-namespaces --watch
```
To see nodes status
```
kubectl get nodes
```
Check kubelet service status
```
sudo systemctl status kubelet.service
```

Check out the static pods manifests
```
ls /etc/kubernetes/manifests
sudo more /etc/kubernetes/manifests/etcd.yaml
sudo more /etc/kubernetes/manifests/kube-apiserver.yaml
```
Check out the conf of static pods on /etc/kubernetes
## Worker nodes
Now to join the other nodes (workers) to the cluster go to the control plane node :
```
sudo kubeadm token create --print-join-command
```
![alt text](image-2.png)
Then copy the output command and paste it on the others worker nodes

Finally test the installation on control plane by running :
See all the pods status 
```
kubectl get pods --all-namespaces --watch
```
To see nodes status
```
kubectl get nodes
```