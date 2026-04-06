# aws-terraform-blueprints

Production-style AWS infrastructure built with Terraform, covering progressively complex architectures from single-tier deployments to containerized workloads with observability.

Built as part of [aws-infra-forge](https://github.com/kratosvil) — a hands-on infrastructure engineering practice by **Samir Villa**.

---

## Overview

This repository contains modular Terraform blueprints for real-world AWS infrastructure patterns. Each blueprint is self-contained, follows IaC best practices, and is designed to be deployed, validated, and torn down safely.

| Blueprint | Architecture | Status |
|-----------|-------------|--------|
| `01-single-tier` | VPC + EC2 + Apache | In Progress |
| `02-two-tier` | EC2 + RDS (public/private segmentation) | Planned |
| `03-docker-cloudwatch` | EC2 + Docker + CloudWatch Logs + IAM | Planned |

---

## Stack

- **Cloud:** AWS (Free Tier)
- **IaC:** Terraform >= 1.0 / AWS Provider ~> 5.0
- **Compute:** EC2 (Amazon Linux 2)
- **Networking:** VPC, Subnets, IGW, Route Tables, Security Groups
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

| Resource | Name |
|----------|------|
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
| `instance_type` | `t2.micro` | EC2 instance type |
| `ami_id` | `ami-0c02fb55956c7d316` | Amazon Linux 2 (us-east-1) |
| `key_name` | `""` | EC2 key pair (optional) |

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

Access the deployed server at the `web_url` output value. To tear down:

```bash
terraform destroy
```

> AMI default targets `us-east-1`. Update `ami_id` variable for other regions.
> Restrict SSH `cidr_blocks` before deploying in shared or production environments.

---

## Author

**Samir Villa** — DevOps / MLOps Infrastructure Engineer
[github.com/kratosvil](https://github.com/kratosvil)
