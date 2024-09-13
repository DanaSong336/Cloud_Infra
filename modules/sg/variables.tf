variable "security_groups" {
  description = "Map of security groups"
  type = map(object({
    name = string
    ingress = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), null) # cidr_blocks를 선택 사항으로 설정
      security_groups = optional(list(string), null) # security_groups를 선택 사항으로 설정
    }))
    egress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
}

variable "vpc_id" {
  description = "The VPC ID where the security groups will be created"
  type        = string
}
