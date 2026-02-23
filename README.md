
#  ML Engineering Platform

Cloud-native Machine Learning Platform built on **Amazon EKS**, designed with **GitOps, Infrastructure as Code, and  MLOps practices**.

This repository demonstrates how to build, operate, and scale a Kubernetes-native ML platform using:

* Terraform (Infrastructure as Code)
* Amazon EKS
* ArgoCD (GitOps)
* Argo Workflows (Pipeline orchestration)
* MLflow (Experiment tracking)
* Docker & GitHub Actions (CI/CD)

---

#  Architecture Overview

```
Terraform → AWS (VPC, EKS, IAM, RDS, S3)
                ↓
            ArgoCD (GitOps)
                ↓
         Argo Workflows (ETL + ML)
                ↓
            MLflow (Tracking)
                ↓
             S3 (Artifacts)
```

---

#  Multi-Environment Strategy

The platform supports environment isolation.

```
infra/terraform/environments/
  ├── dev/
  ├── staging/  
  └── prod/      
```

Design principles:

* Separate Terraform state per environment
* Independent EKS clusters per environment
* Dedicated RDS & S3 per environment
* Namespace isolation inside cluster
* No shared secrets across environments

This enables safe promotion:

```
dev → staging → prod
```

---

#  Workflow Orchestration

Daily ETL & ML training is implemented via **Argo CronWorkflows**.

Pipeline stages:

1. Fetch market data
2. Transform data
3. Train ML model
4. Log experiment to MLflow
5. Store artifacts in S3

Properties:

* Containerized
* Stateless
* Kubernetes-native
* Scheduled & reproducible
* Version-controlled via Git

---

#  Observability & Metrics

The platform includes observability considerations:

## Workflow Metrics

* Workflow success / failure rate
* Execution duration
* Retry counts
* Cron execution frequency

## ML Metrics

* Training accuracy
* Loss metrics
* Model version tracking
* Artifact storage size

## Infrastructure Metrics (EKS)

* Pod CPU / memory usage
* Node utilization
* Resource limits & requests enforced
* Failed pod scheduling events

(Planned extensions)

* Prometheus integration
* Grafana dashboards
* Alerting via CloudWatch

---

#  Security & Access Model

* IAM roles per service
* Principle of least privilege
* No hardcoded credentials
* Kubernetes Secrets for runtime config
* Isolated namespaces:

  * argocd
  * mlflow
  * pipeline

EKS access controlled via:

```
AmazonEKSClusterAdminPolicy
```

Access can be restricted per IAM principal.

---

#  Cost Awareness & Optimization Strategy

The platform is designed with cost-conscious principles:

* Small instance class for dev environments
* Resource limits defined in workflow pods
* Separate environment clusters (no noisy neighbour)
* RDS minimal instance size for dev
* S3 lifecycle policy (planned)
* Horizontal scaling only when required

Future enhancements:

* Cluster autoscaler
* Spot instance node group
* Cost monitoring dashboards

---

#  CI/CD

## CI (GitHub Actions)

* Lint & test
* Docker image build
* Immutable image tagging
* Push to registry

## CD (GitOps via ArgoCD)

```
Git Commit → ArgoCD detects → Sync → Deploy
```

No manual production changes via kubectl.

---

#  Repository Structure

```
infra/
 ├── terraform/
 │    └── environments/
 │         └── dev/
 ├── kubernetes/
 │    ├── bootstrap/
 │    ├── applications/
 │    └── workflows/

src/
 ├── etl/
 ├── training/

.github/
  └── workflows/
```

Separation of concerns:

* Infrastructure
* Platform services
* Workloads
* CI/CD

---

#  Platform Limitations

Current limitations:

1. Single-region deployment (eu-west-2)
2. No automated environment promotion
3. No production-level autoscaling
4. No centralized logging aggregation
5. No RBAC fine-grained per team
6. No model registry promotion pipeline
7. No model serving layer (inference not implemented)

This repository focuses on:

* Platform foundation
* Orchestration
* Infrastructure discipline
* GitOps patterns

Rather than full enterprise ML lifecycle management.

---

#  Design Goals

* Reproducible infrastructure
* GitOps-native operations
* Secure secret management
* Cloud-native orchestration
* Clear separation between infra and workload
* Production-style MLOps patterns

---

#  Setup Guide

Full setup instructions available in:

```
docs/setup.md
```

Includes:

* Terraform apply
* EKS kubeconfig setup
* ArgoCD installation
* Secret creation
* MLflow configuration

---

#  Why This Project

This project demonstrates:

* Platform Engineering mindset
* Real-world MLOps architecture
* Kubernetes-native data workflows
* GitOps operations model
* Secure and scalable cloud foundation

It reflects how modern ML platforms are designed in production environments.

