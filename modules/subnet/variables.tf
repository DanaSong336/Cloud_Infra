variable "vpc_id" {}
variable "subnets" {
  description = "List of subnets to create"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    map_public_ip     = bool
    name              = string
  }))
}