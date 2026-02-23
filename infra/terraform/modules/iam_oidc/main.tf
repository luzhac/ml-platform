# App role
resource "aws_iam_policy" "bucket_full_access" {
  name        = "bucket-full-access"
  description = "Full access to specific S3 bucket only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = "${var.s3_arn}"

      },

      {
        Effect = "Allow"
        Action = [

          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl",  
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = "${var.s3_arn}/*"

      }
    ]
  })
}

resource "aws_iam_policy" "dynamodb_access" {
  name        = "dynamodb-access"
  description = " access to specific dynamodb table only"

  policy = jsonencode(

    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "1111",
          "Effect" : "Allow",

          "Action" : [
            "dynamodb:Scan",
            "dynamodb:PutItem"
          ],
          "Resource" : [
            var.dynamodb_arn
          ]
        }
      ]
    }


  )
}

locals {
  oidc_host = replace(var.oidc_provider_url, "https://", "")
}

resource "aws_iam_role" "challenge_app_role" {
  name = "challenge-app-role"

  assume_role_policy = templatefile(
    "${path.module}/irsa-policy.json",
    {
      oidc_provider_arn = var.oidc_provider_arn
      oidc_host         = local.oidc_host
      namespace         = var.namespace
      service_account   = "challenge-sa"
    }
  )
}




resource "aws_iam_role_policy_attachment" "challenge_bucket_attach" {
  role       = aws_iam_role.challenge_app_role.name
  policy_arn = aws_iam_policy.bucket_full_access.arn
}

resource "aws_iam_role_policy_attachment" "challenge_dynamodb_attach" {
  role       = aws_iam_role.challenge_app_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}


# Github action role

resource "aws_iam_policy" "github_terraform_backend_access" {
  name        = "github-terraform-backend-access"
  description = "Allow GitHub Actions to access existing Terraform backend S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
     
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::marscompute-s3-terraform-state-ml"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::marscompute-s3-terraform-state-ml/*"
      }

     
    ]
  })
}




resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}




resource "aws_iam_role" "challenge_github_action_role" {
  name = "github-action-role"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          Principal = {
            Federated = aws_iam_openid_connect_provider.github.arn
          },
          "Action" : "sts:AssumeRoleWithWebIdentity",
          "Condition" : {
            "StringLike" : {
              "token.actions.githubusercontent.com:sub" : "repo:luzhac/ml-platform:*"
            },
            "StringEquals" : {
              "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
            }
          }
        }
      ]
    }

  )
}




resource "aws_iam_role_policy_attachment" "github_ecr_attach" {
  role       = aws_iam_role.challenge_github_action_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}


resource "aws_iam_role_policy_attachment" "github_bucket_full_access" {
  role       = aws_iam_role.challenge_github_action_role.name
  policy_arn = aws_iam_policy.bucket_full_access.arn
}

resource "aws_iam_role_policy_attachment" "github_dynamodb_access" {
  role       = aws_iam_role.challenge_github_action_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

resource "aws_iam_role_policy_attachment" "github_readonly" {
  role       = aws_iam_role.challenge_github_action_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "terraform" {
  role       = aws_iam_role.challenge_github_action_role.name
  policy_arn = aws_iam_policy.github_terraform_backend_access.arn
}

 
# csi

resource "aws_iam_role" "ebs_csi_role" {
  name = "${var.project_name}-ebs-csi-role"

  assume_role_policy = templatefile(
    "${path.module}/irsa-policy.json",
    {
      oidc_provider_arn = var.oidc_provider_arn
      oidc_host         = local.oidc_host
      namespace         = "kube-system"
      service_account   = "ebs-csi-controller-sa"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ebs_csi_attach" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# autoscaler

resource "aws_iam_role" "autoscaler_role" {
  name = "${var.project_name}-cluster-autoscaler-role"

  assume_role_policy = templatefile(
    "${path.module}/irsa-policy.json",
    {
      oidc_provider_arn = var.oidc_provider_arn
       oidc_host         = local.oidc_host
      namespace         = "kube-system"
      service_account   = "cluster-autoscaler"
    }
  )
}

resource "aws_iam_role_policy_attachment" "autoscaler_policy" {
  role       = aws_iam_role.autoscaler_role.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

# mlflow-pipline
resource "aws_iam_role" "mlflow_irsa" {
  name = "${var.project_name}-mlflow-irsa-role"

  assume_role_policy = templatefile(
    "${path.module}/irsa-policy.json",
    {
      oidc_provider_arn = var.oidc_provider_arn
      oidc_host         = local.oidc_host
      namespace         = var.pipeline_namespace
      service_account   = var.pipeline_service_account
    }
  )
}

data "aws_iam_policy_document" "mlflow_s3_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]

    resources = [
      var.mlflow_s3_arn,
      "${var.mlflow_s3_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "mlflow_s3_policy" {
  name   = "${var.project_name}-mlflow-s3-policy"
  policy = data.aws_iam_policy_document.mlflow_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "mlflow_attach" {
  role       = aws_iam_role.mlflow_irsa.name
  policy_arn = aws_iam_policy.mlflow_s3_policy.arn
}


# inference role
resource "aws_iam_role" "inference_irsa" {
  name = "${var.project_name}-inference-irsa-role"

  assume_role_policy = templatefile(
    "${path.module}/irsa-policy.json",
    {
      oidc_provider_arn = var.oidc_provider_arn
      oidc_host         = local.oidc_host
      namespace         = var.inference_namespace
      service_account   = var.inference_service_account
    }
  )
}
resource "aws_iam_role_policy_attachment" "mlflow_attach_inference" {
  role       = aws_iam_role.inference_irsa.name
  policy_arn = aws_iam_policy.mlflow_s3_policy.arn
}