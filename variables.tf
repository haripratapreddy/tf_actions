variable "aws_region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

# variable "num_of_pub_subnets" {
#   type = number
# }

# variable "num_of_pri_subnets" {
#   type = number
# }

variable "pub_subnet_cidr" {
  type = list
}

variable "pri_subnet_cidr" {
  type = list
}

variable "EIP" {
  type = bool
}
