# install argocd

```
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl create namespace argocd

helm install argocd argo/argo-cd -n argocd
```


# setup argocd
```
 

kubectl apply -f infra/kubernetes/bootstrap/root-app.yaml

```


# argocd application yaml

## ArgoCD   CRD：

https://argo-cd.readthedocs.io/en/stable/



https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/

#
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```


kubectl get pods -n argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443


admin   D4IvXNYS4WCBdPUK
$secret = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($secret))


get github pat key.
```

# delete all
```
kubectl delete applications --all -n argocd

kubectl delete namespace challenge-dev


kubectl delete namespace argocd

```