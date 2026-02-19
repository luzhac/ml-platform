
# Run tf file in setup first to prepare the s3 used in Terraform backend.
```
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources
```

# setup aws profile
```
aws sts get-caller-identity
aws configure list

$env:AWS_PROFILE="second-aws"
export AWS_PROFILE=prod

kubectl config get-contexts
kubectl config current-context
```

# make local user access kubectl
```
# only for manul use, created already in eks.tf
aws eks associate-access-policy `
  --cluster-name challenge-dev-cluster `
  --principal-arn arn:aws:iam::996099991204:user/user-admin `
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy `
  --access-scope type=cluster
```
# update kubectl config
```
# Update (or create) kubeconfig file with the EKS cluster endpoint,
# certificate authority data, and IAM authentication configuration.
# This allows kubectl to authenticate to the EKS cluster using AWS IAM.
aws eks update-kubeconfig   --region eu-west-2  --name ml-dev-cluster 

 
aws eks list-access-entries   --cluster-name ml-dev-cluster 

kubectl config get-contexts
kubectl config current-context

# Switch kubectl to use the specified EKS cluster context.
# This ensures kubectl commands are sent to the correct cluster
# when multiple contexts exist in the kubeconfig file.
kubectl config use-context arn:aws:eks:eu-west-2:996099991204:cluster/ml-dev-cluster


```
# modify github repo in oidc

# modify s3 backend for github

# modify s3 name in module s3