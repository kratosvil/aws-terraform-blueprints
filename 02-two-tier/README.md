# Blueprint 02 — Two-Tier Architecture

EC2 web server in a public subnet connected to an RDS MySQL instance in private subnets. Demonstrates network segmentation, security group chaining, and database isolation patterns.

## Architecture

```
Internet
    |
Internet Gateway
    |
VPC (10.0.0.0/16)
    |
    +-- Public Subnet (10.0.1.0/24) — us-east-1a
    |       |
    |   SG: web-sg (HTTP :80, SSH :22)
    |       |
    |   EC2 t3.micro — Apache
    |       |
    |       | MySQL :3306 (internal only)
    |       |
    +-- Private Subnet A (10.0.2.0/24) — us-east-1a
    +-- Private Subnet B (10.0.3.0/24) — us-east-1b
            |
        SG: db-sg (MySQL :3306 from web-sg only)
            |
        RDS MySQL 8.0 — db.t3.micro
```

## Resources

| Resource | Description |
|----------|-------------|
| `aws_vpc` | VPC with DNS support |
| `aws_subnet` x3 | 1 public + 2 private (multi-AZ for RDS) |
| `aws_internet_gateway` | IGW for public subnet |
| `aws_route_table` x2 | Public (with IGW route) + Private (isolated) |
| `aws_security_group` x2 | web-sg (public) + db-sg (chained to web-sg) |
| `aws_instance` | EC2 with Apache + MySQL client |
| `aws_db_subnet_group` | RDS subnet group across 2 AZs |
| `aws_db_instance` | RDS MySQL 8.0, not publicly accessible |

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | Deployment region |
| `project_name` | `lab2` | Resource name prefix |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR |
| `public_subnet_cidr` | `10.0.1.0/24` | Public subnet CIDR |
| `private_subnet_cidr_a` | `10.0.2.0/24` | Private subnet A CIDR |
| `private_subnet_cidr_b` | `10.0.3.0/24` | Private subnet B CIDR |
| `instance_type` | `t3.micro` | EC2 instance type |
| `db_instance_class` | `db.t3.micro` | RDS instance class |
| `db_name` | `appdb` | Database name |
| `db_username` | `admin` | RDS master username |
| `db_password` | — | RDS master password (sensitive) |

## Usage

```bash
terraform init
terraform plan -var="db_password=YourPassword123"
terraform apply -var="db_password=YourPassword123"
```

Destroy when done:

```bash
terraform destroy -var="db_password=YourPassword123"
```

## Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | VPC ID |
| `instance_id` | EC2 instance ID |
| `instance_public_ip` | EC2 public IP |
| `web_url` | HTTP endpoint |
| `db_endpoint` | RDS endpoint (VPC-internal only) |
| `db_name` | Database name |

> RDS `db_endpoint` is only reachable from within the VPC. Use the EC2 instance as a bastion to connect: `mysql -h <db_endpoint> -u admin -p`
