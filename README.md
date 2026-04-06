# Lab 1 — Single Tier Architecture

Despliegue de una instancia EC2 en una VPC pública con servidor Apache via Terraform.

## Arquitectura

```
Internet
    |
Internet Gateway
    |
Public Subnet (10.0.1.0/24)
    |
EC2 (Apache HTTP)
```

## Recursos creados

- VPC con DNS habilitado
- Internet Gateway
- Subnet pública
- Route Table con ruta a Internet
- Security Group (puertos 80 y 22)
- EC2 instance con Apache instalado via user_data

## Uso

### 1. Configurar credenciales AWS

```bash
aws configure
```

### 2. Inicializar Terraform

```bash
terraform init
```

### 3. Revisar el plan

```bash
terraform plan
```

### 4. Aplicar

```bash
terraform apply
```

### 5. Acceder al servidor

Una vez desplegado, el output `web_url` muestra la URL del servidor.

### 6. Destruir recursos

```bash
terraform destroy
```

## Variables

| Variable             | Default                | Descripción                        |
|----------------------|------------------------|------------------------------------|
| `aws_region`         | `us-east-1`            | Región AWS                         |
| `project_name`       | `lab1`                 | Prefijo de nombres de recursos     |
| `vpc_cidr`           | `10.0.0.0/16`          | CIDR de la VPC                     |
| `public_subnet_cidr` | `10.0.1.0/24`          | CIDR de la subnet pública          |
| `instance_type`      | `t2.micro`             | Tipo de instancia EC2              |
| `ami_id`             | `ami-0c02fb55956c7d316`| AMI Amazon Linux 2 (us-east-1)     |
| `key_name`           | `""`                   | Key pair para acceso SSH (opcional)|

## Notas

- El AMI por defecto es Amazon Linux 2 para `us-east-1`. Cambiar si usas otra región.
- El SSH está abierto a `0.0.0.0/0` — restringir en producción.
