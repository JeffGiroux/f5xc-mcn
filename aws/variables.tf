variable "buildSuffix" {
  type        = string
  description = "random build suffix for resources"
}
variable "projectPrefix" {
  type        = string
  description = "projectPrefix name for tagging"
}
variable "resourceOwner" {
  type        = string
  description = "Owner of the deployment for tagging purposes"
}
variable "awsRegion" {
  description = "aws region"
  type        = string
}
variable "ssh_key" {
  description = "SSH public key used to create an EC2 keypair"
  type        = string
  default     = null
}
variable "awsAz1" {
  description = "Availability zone, will dynamically choose one if left empty"
  type        = string
  default     = null
}
variable "awsAz2" {
  description = "Availability zone, will dynamically choose one if left empty"
  type        = string
  default     = null
}
variable "awsAz3" {
  description = "Availability zone, will dynamically choose one if left empty"
  type        = string
  default     = null
}
variable "volterraP12" {
  description = "Location of F5 XC p12 file"
  type        = string
  default     = null
}
variable "volterraUrl" {
  description = "URL of F5 XC api"
  type        = string
  default     = null
}
variable "f5xcTenant" {
  description = "Tenant of F5 XC"
  type        = string
}
variable "f5xcCloudCredAWS" {
  description = "Name of the F5 XC AWS credentials"
  type        = string
}
variable "namespace" {
  description = "F5 XC application namespace"
  type        = string
}
variable "volterraVirtualSite" {
  type        = string
  description = "The name of the F5 XC virtual site that will receive LB registrations."
}

variable "domain_name" {
  type        = string
  description = "The DNS domain name that will be used as common parent generated DNS name of loadbalancers."
  default     = "shared.acme.com"
}
variable "labels" {
  type        = map(string)
  default     = {}
  description = "An optional list of labels to apply to AWS resources."
}
variable "awsLabels" {
  type        = map(string)
  default     = {}
  description = "An optional list of labels to apply to AWS resources."
}
variable "vpcCidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "CIDR IP Address range of the VPC"
}
variable "publicSubnets" {
  type        = list(any)
  default     = ["10.1.10.0/24", "10.1.110.0/24"]
  description = "Public subnet address prefixes"
}
variable "privateSubnets" {
  type        = list(any)
  default     = ["10.1.52.0/24", "10.1.152.0/24"]
  description = "Private subnet address prefixes"
}
variable "sliSubnets" {
  type        = list(any)
  default     = ["10.1.20.0/24", "10.1.120.0/24"]
  description = "Site Local Inside (SLI) subnet address prefixes for F5 XC"
}
variable "workloadSubnets" {
  type        = list(any)
  default     = ["10.1.30.0/24", "10.1.130.0/24"]
  description = "Workload subnet address prefixes for F5 XC"
}
variable "webapp_ami_search_name" {
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20230112"
  description = "AWS AMI search filter to find correct web app (Ubuntu) for region"
}
