variable "account_id" {
  type = string
}
variable "vm_name" {
  type = list(string)
}
variable "machine_type" {
  type = string
}
variable "zone" {
  type = list(string)
}
variable "image" {
  type = string
}
variable "vpc_name" {
  type = string
}
variable "subnet_name" {
  type = string
}
variable "subnet_cidr" {
  type = list(string)
}
variable "region" {
  type = string
}
variable "firewall_name" {
  type = string
}
