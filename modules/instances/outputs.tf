output "myapp_instance_id" {
  value = aws_instance.myapp_instance.id
}

output "myapp_instance_public_ip" {
  value = aws_instance.myapp_instance.public_ip
}

output "myapp_instance_public_dns" {
  value = aws_instance.myapp_instance.public_dns
}