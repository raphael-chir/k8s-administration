# Env, Secrets and Configmaps

## Env usage : Declarative method
### ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
data:
  app.properties: |
    APP_ENV=production
    APP_VERSION=1.0.0
  custom-file.txt: "This is a custom file from ConfigMap."
```
### Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  username: YWRtaW4=    # Base64 ("admin")
  password: c2VjdXJlcGFzc3dvcmQ= # Base64 ("securepassword")
```
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app-container
        image: nginx:latest
        ports:
        - containerPort: 80
        env:
        # Basic env usage
        - name: APP_ENV
          value: "production"
        - name: APP_VERSION
          value: "1.0.0"
        
        # ConfigMap env usage
        - name: CONFIG_VALUE
          valueFrom:
            configMapKeyRef:
              name: my-configmap
              key: key1
        
        # Secret env usage
        - name: SECRET_PASSWORD
          valueFrom:
            secretKeyRef:
              name: my-secret
              key: password
```
## Env usage : Imperative method
### ConfigMap
```
kubectl create configmap my-configmap --from-literal=key1=some-config-value
```
### Secret
```
kubectl create secret generic my-secret --from-literal=password=securepassword
```
### Deployment
```
kubectl create deployment my-app \
  --image=nginx:latest \
  --replicas=3 \
  --dry-run=client -o yaml | kubectl set env --local -f - \
  APP_ENV=production \
  APP_VERSION=1.0.0 \
  CONFIG_VALUE_FROM_CONFIGMAP=my-configmap:key1 \
  SECRET_PASSWORD_FROM_SECRET=my-secret:password | kubectl apply -f -
```
## Volume usage to mount config files
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-volumes
  labels:
    app: app-with-volumes
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app-with-volumes
  template:
    metadata:
      labels:
        app: app-with-volumes
    spec:
      containers:
      - name: app-container
        image: nginx:latest
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config 
        - name: secret-volume
          mountPath: /etc/secret
          readOnly: true
      volumes:
      - name: config-volume
        configMap:
          name: my-configmap
      - name: secret-volume
        secret:
          secretName: my-secret
```
## Accessing a private Container Registry
We can use ```ctr``` to interact directly with containerd
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-private-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-private-app
  template:
    metadata:
      labels:
        app: my-private-app
    spec:
      containers:
      - name: my-private-container
        image: myprivateregistry.com/my-app:1.0.0 
        ports:
        - containerPort: 8080
      imagePullSecrets:
      - name: my-registry-secret 
```
```
kubectl create secret docker-registry my-registry-secret \
  --docker-server=myprivateregistry.com \
  --docker-username=<user> \
  --docker-password=<pwd> \
  --docker-email=<email>
```