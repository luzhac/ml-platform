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
  pipeline_namespace=var.pipeline_namespace
  pipeline_service_account=var.pipeline_service_account
  inference_namespace=var.inference_namespace
  inference_service_account=var.inference_service_account
  mlflow_s3_arn = module.s3.mlflow_s3_arn
}

module "ecr" {
  source       = "../../modules/ecr"
  project_name = var.project_name
  environment  = var.environment
  region       = var.region
}

module "aws_eks_addon" {
  source       = "../../modules/aws_eks_addon"
  project_name = var.project_name
  environment  = var.environment
  region       = var.region
  cluster_name = module.eks.cluster_name
  service_account_role_arn= module.iam_oidc.csi_service_account_role_arn
}
 

module "cluster_autoscaler" {
  source       = "../../modules/cluster_autoscaler"
  project_name = var.project_name
  environment  = var.environment
  region       = var.region
  cluster_name = module.eks.cluster_name
  service_account_role_arn= module.iam_oidc.as_service_account_role_arn

  depends_on = [
  module.eks,
  module.iam_oidc,
  module.aws_eks_addon
]
}
 
module "mlflow_rds" {
  source = "../../modules/rds"
   environment  = var.environment
  region       = var.region
  project_name        = var.project_name

  mlflow_db_username  = var.mlflow_db_username
  mlflow_db_password  = var.mlflow_db_password
  rds_sg_id           = module.eks.cluster_security_group_id
  vpc_id = module.network.vpc_id
  private_subnet_ids = module.network.subnet_private_ids
 
}
