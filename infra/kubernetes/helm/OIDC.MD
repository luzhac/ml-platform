 
---

# AWS Identity & Access Model (Local vs CI/CD vs EKS)

---

# 1️⃣ Identity Types in This System

There are **three different identity mechanisms** involved:

| Environment    | Identity Type     | Credential Type           | Duration         | Security Level |
| -------------- | ----------------- | ------------------------- | ---------------- | -------------- |
| Local Machine  | IAM User          | Access Key (static)       | Long-term        | Medium         |
| GitHub Actions | IAM Role via OIDC | STS Temporary Credentials | Short-term (~1h) | High           |
| EKS Pod (IRSA) | IAM Role via OIDC | STS Temporary Credentials | Short-term       | High           |

---

# 2️⃣ Local Development (IAM User)

### Identity Source

IAM User with Access Key.

### Configuration Location

```
~/.aws/credentials
~/.aws/config
```

### Flow

```
You (Local Machine)
    ↓
AWS Access Key
    ↓
AWS API (ECR, EKS, S3, Terraform)
```

### Notes

* Uses static credentials
* Not recommended for production automation
* Suitable for bootstrap or personal development

---

# 3️⃣ GitHub Actions (OIDC → IAM Role)

### Identity Source

OIDC (OpenID Connect) + IAM Role

### No Access Keys Stored

GitHub does NOT store AWS secrets.

### Flow

```
GitHub Workflow
    ↓
OIDC JWT Token
    ↓
AWS STS (AssumeRoleWithWebIdentity)
    ↓
Temporary IAM Role Credentials
    ↓
Terraform / ECR / EKS
```

### Key Characteristics

* No static credentials
* Temporary credentials
* Role-based permissions
* Secure and recommended for CI/CD

---

# 4️⃣ EKS Pod Access (IRSA)

### Identity Source

Kubernetes ServiceAccount + IAM Role (IRSA)

### Flow

```
Pod
    ↓
Kubernetes ServiceAccount
    ↓
EKS OIDC Provider
    ↓
AWS STS (AssumeRoleWithWebIdentity)
    ↓
Temporary IAM Role Credentials
    ↓
S3 / DynamoDB / ECR
```

### Used For

* Accessing S3
* Accessing DynamoDB
* Pulling images from ECR
* Accessing other AWS services

---

# 5️⃣ Important Distinction: Kubernetes API Access

Accessing Kubernetes API is different from accessing AWS services.

### Local kubectl

```
kubectl
    ↓
aws eks get-token
    ↓
AWS STS
    ↓
Kubernetes API Server
```

### Terraform in CI

```
Terraform
    ↓
OIDC → STS
    ↓
aws_eks_cluster_auth
    ↓
Kubernetes API Server
```

Pods usually do NOT access Kubernetes API directly.

---

# 6️⃣ OIDC vs Access Key

| Feature               | Access Key | OIDC      |
| --------------------- | ---------- | --------- |
| Credential Type       | Static     | Temporary |
| Stored in Repo        | Risky      | No        |
| Rotation Required     | Yes        | No        |
| Security Level        | Lower      | Higher    |
| Recommended for CI/CD | No         | Yes       |

---

# 7️⃣ Bootstrap Problem (Chicken & Egg)

Before GitHub can use OIDC:

You must create:

* OIDC Provider in AWS
* IAM Role for GitHub
* Trust Policy allowing GitHub repo

This initial setup is called:

```
Bootstrap Phase
```

After that:

All infrastructure can be managed automatically.

---

# 8️⃣ Complete Architecture Diagram

```
                ┌─────────────────────┐
                │     Local Machine   │
                │ IAM User + Access   │
                └──────────┬──────────┘
                           ↓
                         AWS API


                ┌─────────────────────┐
                │   GitHub Actions    │
                │   OIDC → IAM Role   │
                └──────────┬──────────┘
                           ↓
                        AWS STS
                           ↓
                Terraform / ECR / EKS


                ┌─────────────────────┐
                │      EKS Pod        │
                │ ServiceAccount+IRSA │
                └──────────┬──────────┘
                           ↓
                        AWS STS
                           ↓
                   S3 / DynamoDB / ECR
```

---

# 9️⃣ Mental Model Summary

All AWS access eventually becomes:

```
IAM User  OR  IAM Role
```

OIDC is simply a secure way to obtain:

```
Temporary IAM Role Credentials
```

---

# 🔟 Short Interview Answer

If asked:

**How does authentication work in your platform?**

You can answer:

> Local development uses IAM user credentials.
> CI/CD uses GitHub OIDC to assume an IAM role via STS.
> Workloads running inside EKS use IRSA to assume IAM roles using the cluster's OIDC provider.
> All production access is role-based and uses temporary credentials.

---
 
