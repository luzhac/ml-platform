

# install aws rescource using terraform

```
$env:AWS_PROFILE="second-aws"

```

# install aws rescourcer

```
ml-engineering\infra\terraform\environments\dev
terraform apply

```
# setup context to connnet kubenetes in local

```
aws eks associate-access-policy `
  --cluster-name ml-dev-cluster `
  --principal-arn arn:aws:iam::996099991204:user/user-admin `
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy `
  --access-scope type=cluster

aws eks update-kubeconfig   --region eu-west-2  --name ml-dev-cluster 
kubectl config use-context arn:aws:eks:eu-west-2:996099991204:cluster/ml-dev-cluster

```
# install argocd

```
prepare env

kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl create secret generic repo-https `
  -n argocd `
  --from-literal=url=https://github.com/luzhac/ml-platform `
  --from-literal=username=$env:GH_USER `
  --from-literal=password=$env:GH_TOKEN `
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f infra/kubernetes/bootstrap/root-app.yaml

```
## setup argocd ui

```
admin q0Jvk3CkpAFICkUn
$secret = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($secret))

kubectl port-forward svc/argocd-server -n argocd 8080:443

```
## setup mlflow username and password

```
kubectl create namespace mlflow
kubectl create secret generic postgres-database-secret `
  -n mlflow `
  --from-literal=username=$env:TF_VAR_mlflow_db_username   `
  --from-literal=password=$env:TF_VAR_mlflow_db_password 

```
## setup workflows


```
kubectl port-forward svc/mlflow -n mlflow 5000:5000

```

kubectl port-forward svc/argo-workflows-server -n argo 2746:2746