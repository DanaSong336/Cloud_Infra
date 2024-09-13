variable "name" {}
variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "security_group_ids" {
  type = list(string)
}
variable "iam_instance_profile" {}
variable "user_data" {}
variable "public_subnet_id" {}