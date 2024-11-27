# k8s deploy

## Imperative deployments
Direct deployment on command line but not convenient for more complex usage.

Here is a deployment creation with 1 replica
```
kubectl create deployment hello-world-app --image=gcr.io/google-samples/hello-app:1.0
```
Here is just a bare pod
```
kubectl run hello-world-app --image=gcr.io/google-samples/hello-app:1.0
```
## Declarative deployments
```
kubectl apply -f deployment.yaml
```
Here is a basic manifest :
```yaml
apiVersion: apps/v1
kind: Deployment #See api resources to list possibilities
metadata:
  name: hello-world #This is here the name of our deployment
spec:
  replicas: 1 
  selector: #selector is a way for a deployment to know which pods are a member of this deployment
    matchLabels:
      app: hello-world
template: #Define the pods created by this deployment aka pod template
  metadata:
    labels:
      app: hello-world
  spec:
    containers:
    - image: gcr.io/google-samples/hello-app:1.0
      name: hello-app
```
## Expose a deployment as a service
Listen to target port and expose with port
```bash
kubectl expose deployment hello-world-app --port=80 --target-port=8080
kubectl get services
```
That's where we access the service from inside the cluster
```bash
ubuntu@cp-node01:~$ kubectl get services 
NAME              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
hello-world-app   ClusterIP   10.103.114.204   <none>        80/TCP    23s
kubernetes        ClusterIP   10.96.0.1        <none>        443/TCP   5d19h
```
Test the access to the endpoint
```
curl 10.103.114.204:80
#or
kubectl get endpoints hello-world-app
curl 192.168.0.201:8080
```
Take a look on the deployment :
```
kubectl get deployment hello-world-app --output json | jq
```
## Generate manifests wit dry-run
As writing a deployment manifest could be complex we can use --dry-run option to define quickly and correctly a manifest. (this will not exec the deployment)
```
kubectl create deployment hello-world --image=gcr.io/google-samples/hello-app:1.0 --dry-run=client -o yaml | more
```
You get this output
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: hello-world
  name: hello-world
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-world
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: hello-world
    spec:
      containers:
      - image: gcr.io/google-samples/hello-app:1.0
        name: hello-app
        resources: {}
status: {}
```
Redirect the command to a file to persist
Do the same for service manifest

Now try to modify deployment and set replicas to anather value, verify the load balancing to the different pod.
You can modify deployment on the fly, scale on the fly
```
kubectl edit deployment ... #Modified in etcd but not reflected in deployment.yaml
kubectl scale deployment hello-world --replicas=40
```