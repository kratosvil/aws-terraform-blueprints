variable "aws_region" {
  description = "Región AWS"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI para la instancia EC2 (Amazon Linux 2)"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "vpc_cidr" {
  description = "CIDR block de la VPC"
  type        = string
  default     = "10.3.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block de la subnet pública"
  type        = string
  default     = "10.3.1.0/24"
}
