# Deployments
## Easy yaml generation and apply
```bash
kubectl create deployment hello-app --image=gcr.io/google-samples/hello-app:1.0 --replicas 10 --dry-run=client --output yaml >> deployment-lab.yaml \
&& echo "---" >> deployment-lab.yaml \
&& kubectl create service clusterip hello-app --tcp=80:8080 --dry-run=client -o yaml >> deployment-lab.yaml
```
We obtain :
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: hello-app
  name: hello-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-app
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: hello-app
    spec:
      containers:
      - image: gcr.io/google-samples/hello-app:1.0
        name: hello-app
        resources: {}
status: {}
---
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: hello-app
  name: hello-app
spec:
  ports:
  - name: 80-8080
    port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: hello-app
  type: ClusterIP
status:
  loadBalancer: {}
```

Here is the list of service type :

- **ClusterIP**: 
  - Used for internal communication only. 
  - It is the default Service type.
  - Pods and other objects in the cluster can access the Service, but it is not accessible externally.

- **NodePort**: 
  - Exposes the application on a specific port of each node's IP. 
  - Useful for testing or direct access from an external network without requiring a LoadBalancer.
  - Requires clients to manage node IPs manually if there are multiple nodes.

- **LoadBalancer**: 
  - Provides external access to the application through a cloud-managed or custom load balancer.
  - Ideal for public-facing services with automated traffic distribution.
  - Often incurs additional costs if using a cloud provider.

- **ExternalName**: 
  - Redirects traffic to an external DNS name.
  - Does not manage traffic routing or load balancing.
  - Commonly used for aliasing external services like managed databases or third-party APIs.

```bash
kubectl apply -f deployment-lab.yaml 
deployment.apps/hello-world created
service/hello-world configured
kubectl get deployments.apps hello-app
```
## Rollout
Update image to 2.0 and apply. The perform :
```
ubuntu@cp-node01:~$ kubectl apply -f deployment-lab.v2.yaml
deployment.apps/hello-app configured
service/hello-app configured

ubuntu@cp-node01:~$ kubectl rollout status deployment hello-app
Waiting for deployment "hello-app" rollout to finish: 5 out of 10 new replicas have been updated...
Waiting for deployment "hello-app" rollout to finish: 5 out of 10 new replicas have been updated...
Waiting for deployment "hello-app" rollout to finish: 5 out of 10 new replicas have been updated...
Waiting for deployment "hello-app" rollout to finish: 5 out of 10 new replicas have been updated...
Waiting for deployment "hello-app" rollout to finish: 5 out of 10 new replicas have been updated...
Waiting for deployment "hello-app" rollout to finish: 6 out of 10 new replicas have been updated...
Waiting for deployment "hello-app" rollout to finish: 6 out of 10 new replicas have been updated...
Waiting for deployment "hello-app" rollout to finish: 7 out of 10 new replicas have been updated...
Waiting for deployment "hello-app" rollout to finish: 7 out of 10 new replicas have been updated...
Waiting for deployment "hello-app" rollout to finish: 7 out of 10 new replicas have been updated...
Waiting for deployment "hello-app" rollout to finish: 3 old replicas are pending termination...
Waiting for deployment "hello-app" rollout to finish: 3 old replicas are pending termination...
Waiting for deployment "hello-app" rollout to finish: 3 old replicas are pending termination...
Waiting for deployment "hello-app" rollout to finish: 2 old replicas are pending termination...
Waiting for deployment "hello-app" rollout to finish: 2 old replicas are pending termination...
Waiting for deployment "hello-app" rollout to finish: 2 old replicas are pending termination...
Waiting for deployment "hello-app" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "hello-app" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "hello-app" rollout to finish: 8 of 10 updated replicas are available...
Waiting for deployment "hello-app" rollout to finish: 9 of 10 updated replicas are available...
deployment "hello-app" successfully rolled out
```
See the return code. If 0 we are in the complete status
```bash
echo $?
0
```
Make a describe on the deployment and replicaset
```
kubectl describe deployments.apps hello-app 
```
```
ubuntu@cp-node01:~$ kubectl get replicasets.apps 
NAME                  DESIRED   CURRENT   READY   AGE
hello-app-556c89d9f   0         0         0       23m
hello-app-6fddf46cb   10        10        10      4m48s
```
Make a describe on theses replicaset

## Change the state of a deployment
You can :
- Update the strategy
  - RollingUpdate (default scale in old while scale out new)
    - maxUnavailable : unsure only certain number of pods are unavailable being updated (default 25%). Set a % or un number
    - maxSurge : unsure that only certain number of pods are created above the desired number of pods (default 25%). Set a % or un number
  - Recreate (Terminate old version and scale out new version) - Used if 2 versions can't cohabitate
  - Use a readinessProbe in pod template spec
- Pause to make corrections
- Rollback
- Restart a deployment

### Explore Rollout features
You can be aware of problems regarding a rollout by using the parameter ```progressDeadlineSeconds``` in spec of your deployment : 
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  progressDeadlineSeconds: 600 #default value that can be decreased for deployment that need to be aware sooner
...
```
Let's create a broken deployment by a bad image :
```
ubuntu@cp-node01:~$ kubectl apply -f deployment-lab.broken.yaml 
deployment.apps/hello-app configured
service/hello-app configured
ubuntu@cp-node01:~$ echo $?
0
ubuntu@cp-node01:~$ kubectl rollout status deployment hello-app 
error: deployment "hello-app" exceeded its progress deadline
ubuntu@cp-node01:~$ echo $?
1
```
Perform a describe on the deployment to understand the strategy applied (default one).  
Now we can take a look on rollout history (note that change-cause is filled by <none> because we didn't use --record options):
```
kubectl rollout history deployment hello-world
deployment.apps/hello-app 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         <none>
```
See the change between revision with :
```
kubectl rollout history deployment hello-app --revision 2
```
You can undo to a revision
```
kubectl rollout undo deployment hello-app --to-revision 2
```

### Advanced Rollout configuration
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-app
spec:
  replicas: 20
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 10%
      maxSurge: 2
  revisionHistoryLimit: 20
  selector:
    matchLabels:
      name: hello-app
  template:
    metadata:
      labels:
        name: hello-app
    spec:
      containers:
      - name: hello-app
        image: gcr.io/google-samples/hello-app:1.0
        ports:
        - containerPort: 8080
        readinessProbe: 
          httpGet:
            path: /index.html 
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: hello-app
  name: hello-app
spec:
  ports:
  - name: 80-8080
    port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: hello-app
  type: ClusterIP
status:
  loadBalancer: {}
```
Deploy this manifest, and observe with describe the status of this deployment.  
Let's create a second manifest with hell-app:2.0.  
Control the diff
```
diff deployment-probes-1.yaml deployments-probes-2.yaml
```
Deploy the new version. Observe with describe or :
```
kubectl get replicasets.apps
```
Let's cretae a third manifest with a typo in httpGet port in readinessProbe (set 8081). Observe that rollout deployment is stopped due to readinessProbe control.
Check rollout history :
```
ubuntu@cp-node01:~$ kubectl rollout history deployment hello-app 
deployment.apps/hello-app 
REVISION  CHANGE-CAUSE
1         kubectl apply --filename=deployment-probes-1.yaml --record=true
2         kubectl apply --filename=deployment-probes-2.yaml --record=true
3         kubectl apply --filename=deployment-probes-3.yaml --record=true
```
Get more details on a revision with :
```
kubectl rollout history deployment hello-app --revision 3
kubectl rollout history deployment hello-app --revision 2
```
And then undo to the revision :
```
kubectl rollout undo deployment hello-app --to-revision 2
```
### Why Use `rollout restart`?

#### Apply Updates Without Modifying the Manifest
If you update a ConfigMap or a Secret used by your Pods, a restart is necessary to apply the changes. `rollout restart` allows you to do this without directly editing the manifest.

#### Resolve Issues
If Pods are in a degraded or stuck state, this command recreates them to restore functionality.

#### Pod Lifecycle Management
It is useful for simulating a redeployment or applying a progressive update, leveraging Kubernetes' update strategy, such as **RollingUpdate**.

## Scaling deployments
```
kubectl scale deployment hello-app --replicas 15
```
You can do it decalartively in the manifest or use Horizontal Pod Autoscaler, that be more reactive.

