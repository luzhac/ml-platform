# EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = "${var.project_name}-${var.environment}-cluster"
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    
  }



  version = "1.33"

  access_config {
    authentication_mode = "API"
  }
  tags = {
    Project = var.project_name
  Environment = var.environment }

}

# just for test , not use in production
resource "aws_security_group_rule" "allow_nodeport_31642" {
  type              = "ingress"
  security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id

  from_port   = 31642
  to_port     = 31642
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  description = "Allow NodePort 31642 for LoadBalancer service"
}



# EKS Node Group
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "default"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  instance_types = ["t3.medium"]
  ami_type       = "AL2023_x86_64_STANDARD"

  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }


  tags = {
    Project     = var.project_name
    Environment = var.environment
  }

  capacity_type = "ON_DEMAND"
  disk_size     = 30
}


# Current caller IAM
data "aws_caller_identity" "current" {}


# Access Entry for admin
resource "aws_eks_access_entry" "admin_access" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.aws_caller_identity.current.arn
  type          = "STANDARD"

  lifecycle {
    ignore_changes = [principal_arn]
  }
}

 
resource "aws_eks_access_policy_association" "terraform_admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.aws_caller_identity.current.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}



# 
data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

