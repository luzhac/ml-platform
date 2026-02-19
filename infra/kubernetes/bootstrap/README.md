# instal argocd first

# set env and run
```
 
kubectl create secret generic repo-https `
  -n argocd `
  --from-literal=url=https://github.com/luzhac/ml-platform `
  --from-literal=username=$env:GH_USER `
  --from-literal=password=$env:GH_TOKEN `
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f infra/kubernetes/bootstrap/root-app.yaml

kubectl apply -f root-app.yaml
```

# 
```
GitHub → Settings → Secrets → Actions
GH_USER
GH_TOKEN

# Idempotent
- name: Create ArgoCD repo secret
  run: |
    kubectl create secret generic repo-https \
      -n argocd \
      --from-literal=url=https://github.com/luzhac/platform-v2 \
      --from-literal=username=${{ secrets.GH_USER }} \
      --from-literal=password=${{ secrets.GH_TOKEN }} \
      --dry-run=client -o yaml | kubectl apply -f -

```