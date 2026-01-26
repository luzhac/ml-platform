

# Install kubenetes
## Context env
kubectl config get-contexts

kubectl config use-context docker-desktop

## Install using local kubetenes

choco install k3d -y

k3d version

### mount 
k3d cluster create dev \
  --servers 1 \
  --agents 2 \
  --volume "/mnt/c/Myfiles/ETL/data:/mnt/etl-data@all"






kubectl create ns argo

## prepare install argo
kubectl create serviceaccount argo-workflow -n argo

cd /mnt/c/myfiles/myprojects/ml-engineering/pipelines/platform

kubectl apply -f argo-workflow-clusterrole.yaml

kubectl create clusterrolebinding argo-workflow-binding \
  --clusterrole=argo-workflow \
  --serviceaccount=argo:argo-workflow




k3d cluster delete dev

 k3d cluster list

## get image using ecr 
Windows
 └─ WSL
     ├─ docker login ECR
     ├─ kubectl create secret ecr-secret
     └─ k3d cluster
          └─ Argo Workflow Pod
               └─ pulls image from ECR

aws sts get-caller-identity



# Avoid get token every time pull image
kubectl create secret docker-registry ecr-pull-secret \
  --docker-server=173381466759.dkr.ecr.ap-northeast-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password="$(aws ecr get-login-password --region ap-northeast-1)" \
  --namespace argo

kubectl patch serviceaccount argo-workflow \
  -n argo \
  -p '{"imagePullSecrets":[{"name":"ecr-pull-secret"}]}'



 


## mount local disk

