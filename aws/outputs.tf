output "vpcId" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}
output "webserver_private_ip" {
  value       = module.webapp.private_ip
  description = "Private IP address of web server"
}
output "webserver_public_ip" {
  value       = module.webapp.public_ip
  description = "Public IP address of web server"
}
