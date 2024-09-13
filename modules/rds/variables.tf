variable "sg_name" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "storage" {}
variable "engine" {}
variable "engine_version" {}
variable "class" {}
variable "db_name" {}
variable "username" {}
variable "password" {}
variable "parameter_group_name" {}
variable "vpc_security_group_ids" {
  type = list(string)
}
variable "tag" {}