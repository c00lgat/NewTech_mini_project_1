variable "vpc_cidr_block" {
    description = "The VPC CIDR block"
    type = string
    default = "10.0.0.0/16"
}

variable "main_public_subnet_cidr" {
    description = "The public subnet CIDR block"
    type = string
    default = "10.0.1.0/24"
}

variable "secondary_public_subnet_cidr" {
    description = "The public subnet CIDR block"
    type = string
    default = "10.0.2.0/24"
}