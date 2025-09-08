Sisense on AWS EKS — Terraform Deployment
Overview

This repository provides a production-ready, modular Terraform setup to deploy Sisense on AWS EKS. It covers:

VPC, Subnets, IGW, Route Tables

Security Groups

EKS Cluster & Node Groups

FSx Lustre + EBS CSI

Kubernetes Addons (EBS CSI driver, Cluster Autoscaler)

DNS / Route53

Node bootstrap scripts

It is fully modular, environment-agnostic, and supports Dev, Staging, and Production deployments.

Directory Structure
.
├── modules/
│   ├── vpc/
│   ├── security-groups/
│   ├── eks/
│   ├── nodegroups/
│   ├── storage/
│   ├── addons/
│   ├── dns/
│   └── iam/
├── userdata/
│   └── bootstrap.sh
├── main.tf
├── providers.tf
├── versions.tf
├── backend.tf
├── dev.tfvars
└── prod.tfvars

Prerequisites

Terraform >= 1.6.0

AWS CLI v2 configured

IAM permissions to create:

VPC, Subnets, SGs, Route53

EKS cluster, Node Groups, IAM Roles

FSx Lustre

DynamoDB table and S3 bucket for Terraform remote state

Access to Docker Hub (or private registry) for Sisense containers

Deployment Instructions
1. Initialize Terraform
terraform init 


This configures the remote backend and downloads all required providers.

2. Select Environment

Development / Staging:

terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"


Production:

terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"

3. Verify Resources
EKS Cluster
aws eks --region <region> describe-cluster --name <cluster_name>
kubectl get nodes

FSx Lustre
aws fsx describe-file-systems

Node Labels (for Sisense)

Application nodes: node-sisense-application=true

Query nodes: node-sisense-query=true

Build nodes: node-sisense-build=true

kubectl get nodes --show-labels

4. Node Bootstrap

The userdata/bootstrap.sh script installs:

Python3, pip, nc, jq, sshpass, git, libselinux-python3

Updates Docker ulimits

Configures node for Sisense deployment

Userdata is automatically injected into each node group during provisioning.

5. Kubernetes Addons

EBS CSI driver: Manages persistent EBS volumes for Sisense

Cluster Autoscaler: Dynamically scales node groups based on workload

Helm releases are managed via Terraform.

6. DNS / Networking

Route53 hosted zone is created per environment (dev.sisense.example.com or sisense.example.com)

SGs allow inter-node communication and FSx Lustre access

Nodes must have outbound internet access to Docker Hub / ECR

7. IAM Roles

Node IAM Role: For EKS nodes (managed policies attached)

EBS CSI IAM Role: For CSI driver using OIDC provider

All roles are created via Terraform; no hardcoded ARNs

8. Upgrades / Maintenance

Update k8s_version in dev.tfvars or prod.tfvars

Run:

terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"


Verify node labels and FSx mounts

9. Outputs

After deployment, Terraform outputs:

eks_cluster_name

eks_oidc_provider_arn

fsx_dns_name

route53_zone_id

These are needed by Sisense engineers for Helm deployment and configuration.

10. Notes / Best Practices

Node labels must match Sisense configuration (Application, Query, Build)

Minimum pod per node: 58

Ensure /etc/resolv.conf uses Amazon DNS (169.254.169.253) if required

Docker ulimit must be increased as part of bootstrap.sh

FSx Lustre minimum storage: 1024 GB

11. References

Sisense EKS Deployment Docs

Sisense Helm Installation

Terraform AWS EKS Module

This README ensures both DevOps and Sisense engineers have a single source of truth for deploying and maintaining Sisense on AWS EKS.
