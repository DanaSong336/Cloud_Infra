variable "lt_id" {}
variable "min_size" {}
variable "max_size" {}
variable "desired_capacity" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "health_check_type" {}
variable "key" {}
variable "value" {}
variable "target_group_arns" {
  type = list(string)
}