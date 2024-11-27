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
## Generate manifests wit dry-run

