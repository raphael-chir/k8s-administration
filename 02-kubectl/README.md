# kubectl
kubectl CLI interact with the control plane api-server, here is a list of its mandatory usage to facilitate k8s exploitation.

## Auto complete
Just simplify our life !
```
sudo apt-get install -y bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc
```
## Which cluster is your current context
```
kubectl cluster-info
```
## Review status, roles and version
```
kubectl get nodes
kubectl get nodes -o wide
kubectl get nodes --output wide
```
## Review pods
```
kubectl get pods (default namespace)
kubectl get pods --all-namespaces
kubectl get pods --namespace kubesystem
kubectl get pods --namespace kubesystem --output wide
```
## Review everything running in the cluster
```
kubectl get all --all-namespaces | more
```
## List all api resources
```
kubectl api-resources | more
kubectl get namespaces or kubectl get ns
kubectl api-resources | grep pod
```
## Explain an individual resource in details
Very useful to get documentation on fields  available
```
kubectl explain pod | more
kubectl explain pod.spec | more
kubectl explain pod --recursive | more
```
## Describe an object
Useful to get precise information of an object 
```
kubectl describe nodes cp-node01 | more
```
## Help
```
kubectl -h | more
kubectl -h apply | more
kubectl get -h | more
kubectl create -h | more
...
```
