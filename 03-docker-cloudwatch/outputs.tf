output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "IP pública de la instancia EC2"
  value       = aws_instance.web.public_ip
}

output "api_url" {
  description = "URL de la API"
  value       = "http://${aws_instance.web.public_ip}"
}

output "cloudwatch_log_group" {
  description = "Nombre del Log Group en CloudWatch"
  value       = aws_cloudwatch_log_group.api.name
}
