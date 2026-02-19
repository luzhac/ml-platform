module "network" {
  source       = "../../modules/network"
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  region       = var.region
}

module "s3" {
  source       = "../../modules/s3"
  project_name = var.project_name
  environment  = var.environment
  region       = var.region
}

module "dynamodb" {
  source       = "../../modules/dynamodb"
  project_name = var.project_name
  environment  = var.environment
  region       = var.region
}

module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
  environment  = var.environment
  region       = var.region
}


module "eks" {
  source       = "../../modules/eks"
  project_name = var.project_name
  environment  = var.environment
  region       = var.region

  cluster_role_arn = module.iam.eks_cluster_role
  node_role_arn    = module.iam.eks_node_role
  subnet_ids       = module.network.subnet_private_ids
  
   
}

module "iam_oidc" {
  source       = "../../modules/iam_oidc"
  project_name = var.project_name
  environment  = var.environment
  region       = var.region

  s3_arn            = module.s3.s3_bucket_challenge_arn
  dynamodb_arn      = module.dynamodb.challenge_dynamodb_table_arn
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  namespace=var.namespace
}

module "ecr" {
  source       = "../../modules/ecr"
  project_name = var.project_name
  environment  = var.environment
  region       = var.region
}

 
 
