output "vnetId" {
  description = "VNet ID"
  value       = module.network.vnet_id
}
output "webserver_private_ip" {
  value       = azurerm_network_interface.webserver.private_ip_address
  description = "Private IP address of web server"
}
output "webserver_public_ip" {
  value       = azurerm_public_ip.webserver[0].ip_address
  description = "Public IP address of web server"
}
