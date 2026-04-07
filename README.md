# aws-terraform-blueprints

Production-style AWS infrastructure built with Terraform, covering progressively complex architectures from single-tier deployments to containerized workloads with observability.

Built as part of [aws-infra-forge](https://github.com/kratosvil) — a hands-on infrastructure engineering practice by **Samir Villa**.

---

## Overview

This repository contains modular Terraform blueprints for real-world AWS infrastructure patterns. Each blueprint is self-contained, follows IaC best practices, and is designed to be deployed, validated, and torn down safely.

| Blueprint | Architecture | Status |
|-----------|-------------|--------|
| [`01-single-tier`](./01-single-tier/) | VPC + EC2 + Apache | Complete |
| [`02-two-tier`](./02-two-tier/) | EC2 + RDS (public/private segmentation) | Complete |
| [`03-docker-cloudwatch`](./03-docker-cloudwatch/) | EC2 + Docker + CloudWatch Logs + IAM | Complete |

---

## Stack

- **Cloud:** AWS (Free Tier)
- **IaC:** Terraform >= 1.0 / AWS Provider ~> 5.0
- **Compute:** EC2 t3.micro (Amazon Linux 2)
- **Networking:** VPC, Subnets, IGW, Route Tables, Security Groups
- **Database:** RDS MySQL 8.0
- **Containers:** Docker (bootstrapped via user_data)
- **Observability:** CloudWatch Logs
- **Security:** IAM Roles, Instance Profiles, Security Groups
- **Automation:** user_data bootstrap scripts

---

## Blueprint 01 — Single Tier

Public EC2 web server in a dedicated VPC with full network configuration automated via Terraform.

### Architecture

```
Internet
    |
Internet Gateway
    |
VPC (10.0.0.0/16)
    |
Public Subnet (10.0.1.0/24)
    |
Security Group (HTTP :80, SSH :22)
    |
EC2 — Apache HTTP Server
```

### Resources

| Resource | Description |
|----------|-------------|
| `aws_vpc` | Custom VPC with DNS support |
| `aws_subnet` | Public subnet with auto-assign public IP |
| `aws_internet_gateway` | IGW attached to VPC |
| `aws_route_table` | Public route table (0.0.0.0/0 -> IGW) |
| `aws_security_group` | HTTP + SSH inbound |
| `aws_instance` | EC2 with Apache bootstrapped via user_data |

### Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | Deployment region |
| `project_name` | `lab1` | Resource name prefix |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `public_subnet_cidr` | `10.0.1.0/24` | Public subnet CIDR |
| `instance_type` | `t3.micro` | EC2 instance type |
| `ami_id` | — | Amazon Linux 2 AMI ID for target region |

### Outputs

| Output | Description |
|--------|-------------|
| `instance_id` | EC2 instance ID |
| `instance_public_ip` | Public IP |
| `instance_public_dns` | Public DNS |
| `web_url` | HTTP endpoint |
| `vpc_id` | VPC ID |

### Usage

```bash
terraform init
terraform plan
terraform apply
```

> Always verify the current Amazon Linux 2 AMI ID before deploying:
> ```bash
> aws ec2 describe-images --region us-east-1 --owners amazon \
>   --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" "Name=state,Values=available" \
>   --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text
> ```
> Restrict SSH `cidr_blocks` before deploying in shared or production environments.

---

## Blueprint 02 — Two Tier

Segmented architecture with a public web tier (EC2) and a private database tier (RDS MySQL), connected via Security Group chaining.

### Architecture

```
Internet
    |
Internet Gateway
    |
VPC (10.2.0.0/16)
    |
Public Subnet (10.2.1.0/24)          Private Subnets (10.2.3.0/24, 10.2.4.0/24)
    |                                         |
Security Group (HTTP :80, SSH :22)    Security Group (MySQL :3306 from web SG only)
    |                                         |
EC2 — Apache + MySQL client           RDS MySQL 8.0 (db.t3.micro)
```

### Resources

| Resource | Description |
|----------|-------------|
| `aws_vpc` | Custom VPC with DNS support |
| `aws_subnet` (x3) | 1 public + 2 private (required by RDS subnet group) |
| `aws_internet_gateway` | IGW attached to VPC |
| `aws_route_table` (x2) | Public (with IGW) + private (no internet route) |
| `aws_security_group` (x2) | Web SG (HTTP/SSH) + DB SG (MySQL from web SG only) |
| `aws_instance` | EC2 with Apache + MySQL client via user_data |
| `aws_db_subnet_group` | RDS subnet group across 2 AZs |
| `aws_db_instance` | RDS MySQL 8.0, privately accessible only |

### Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | Deployment region |
| `vpc_cidr` | `10.2.0.0/16` | VPC CIDR block |
| `instance_type` | `t3.micro` | EC2 instance type |
| `ami_id` | — | Amazon Linux 2 AMI ID for target region |
| `db_username` | — | RDS master username |
| `db_password` | — | RDS master password (use tfvars, never hardcode) |

### Outputs

| Output | Description |
|--------|-------------|
| `instance_id` | EC2 instance ID |
| `public_ip` | EC2 public IP |
| `web_url` | HTTP endpoint |
| `db_endpoint` | RDS endpoint (internal only) |

### Key Design Decisions

- RDS requires a DB subnet group with at least 2 subnets in different AZs
- Security Group chaining: DB SG allows MySQL only from the web SG — not from a CIDR
- `publicly_accessible = false` — RDS is unreachable from the internet
- Private route table has no `0.0.0.0/0` route — RDS has no internet egress

---

## Blueprint 03 — Docker + CloudWatch

Containerized API running on EC2 with Docker, fully bootstrapped via user_data, sending logs to CloudWatch via the native `awslogs` driver. IAM Role grants the instance permissions to write logs without hardcoded credentials.

### Architecture

```
Internet
    |
Internet Gateway
    |
VPC (10.3.0.0/16)
    |
Public Subnet (10.3.1.0/24) — us-east-1a
    |
Security Group (HTTP :80, SSH :22)
    |
EC2 t3.micro
  └── IAM Instance Profile (CloudWatch write permissions)
  └── Docker (installed via user_data)
       └── Flask API container (port 80)
            └── awslogs driver → CloudWatch Log Group /lab3/api
```

### Resources

| Resource | Description |
|----------|-------------|
| `aws_vpc` | Custom VPC with DNS support |
| `aws_subnet` | Public subnet, pinned to us-east-1a |
| `aws_internet_gateway` | IGW attached to VPC |
| `aws_route_table` | Public route table (0.0.0.0/0 -> IGW) |
| `aws_security_group` | HTTP + SSH inbound, full egress |
| `aws_iam_role` | EC2 assume role policy |
| `aws_iam_role_policy` | CloudWatch Logs write permissions |
| `aws_iam_instance_profile` | Binds IAM role to EC2 |
| `aws_instance` | EC2 with Docker + Flask API via user_data |
| `aws_cloudwatch_log_group` | Log group `/lab3/api` with 1-day retention |

### Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | Deployment region |
| `vpc_cidr` | `10.3.0.0/16` | VPC CIDR block |
| `subnet_cidr` | `10.3.1.0/24` | Public subnet CIDR |
| `instance_type` | `t3.micro` | EC2 instance type |
| `ami_id` | — | Amazon Linux 2 AMI ID for target region |

### Outputs

| Output | Description |
|--------|-------------|
| `instance_id` | EC2 instance ID |
| `public_ip` | EC2 public IP |
| `api_url` | HTTP endpoint of the Flask API |
| `cloudwatch_log_group` | CloudWatch Log Group name |

### How the bootstrap works

The `user_data.sh` script runs once on first boot and:
1. Installs Docker and enables it as a system service
2. Writes `app.py` and `Dockerfile` to disk via heredoc
3. Builds the Docker image locally (`docker build`)
4. Runs the container with `--log-driver=awslogs` pointing to `/lab3/api`

No external registry is needed — the image is built on the instance at launch time.

### IAM flow

```
EC2
 └── Instance Profile      ← connector between EC2 and IAM Role
      └── IAM Role         ← identity EC2 can assume
           └── Policy      ← allows logs:CreateLogGroup, logs:PutLogEvents, etc.
```

Without the Instance Profile, the `awslogs` driver calls to CloudWatch are rejected with 403.

---

## Notes

- **Instance type:** use `t3.micro` — `t2.micro` is not Free Tier eligible on new AWS accounts
- **AMI IDs:** always verify the current ID before deploying (see Blueprint 01 usage note)
- **Secrets:** never hardcode credentials — use `terraform.tfvars` (gitignored) or Kubernetes/AWS Secrets Manager
- **Cost control:** always run `terraform destroy` after validating each lab

---

## Author

**Samir Villa** — DevOps / MLOps Infrastructure Engineer
[github.com/kratosvil](https://github.com/kratosvil)
