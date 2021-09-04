# variables

# path to public key on the local machine
variable "public_key_path" {}

variable "azure_subscription_id" {}
variable "region" {
  default = "Norway East" 
}
variable "admin_username" {
  default = "adminuser"
}
variable "network_address_space" {
  default = "10.0.0.0/16"
}
variable "subnet_address_space" {
  default = "10.0.2.0/24"
}
