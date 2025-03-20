### This repository contains code for the following blog post.
## www.nahidsaikat.com/blog/setup-key-auth-plugin-in-kong-api-gateway-on-kubernetes-minikube/

#### Run the following commands
```bash
minikube start
kubectl apply -f deploy.yaml
kubectl apply -f service.yaml
helm repo add kong https://charts.konghq.com
helm repo update
helm install kong kong/ingress -n kong --create-namespace
kubectl apply -f kong-routes.yaml
kubectl apply -f auth.yaml
minikube service kong-gateway-proxy -n kong
```

Finally open the url from the terminal outpur in the browser.
