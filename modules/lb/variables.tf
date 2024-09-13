variable "name" {}
variable "type" {}
variable "security_group_ids" {
  type = list(string)
}
variable "public_subnet_ids" {
  type = list(string)
}
variable "tag" {}
variable "tg_name" {}
variable "tg_port" {}
variable "tg_protocol" {}
variable "vpc_id" {}
variable "tg_tag" {}
