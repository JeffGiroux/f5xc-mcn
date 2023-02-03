output "vpcId" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}
output "webserver_private_ip" {
  value       = aws_instance.webserver.private_ip
  description = "Private IP address of web server"
}
output "webserver_public_ip" {
  value       = aws_eip.webserver.public_ip
  description = "Public IP address of web server"
}
output "webserver_public_dns" {
  value       = aws_eip.webserver.public_dns
  description = "Public DNS name of web server"
}
