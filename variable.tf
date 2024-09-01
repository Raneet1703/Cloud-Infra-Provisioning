variable "cidr_vpc" {
  default = "192.168.0.0/16"
}

variable "cidr_subnet_1" {
  type        = string
  default     = "192.168.1.0/24"
  description = "public_subnet-1"
}

variable "cidr_subnet_2" {
  type        = string
  default     = "192.168.2.0/24"
  description = "public_subnet-2"
}

variable "internet_gateway" {
  type        = string
  description = "internet gateway name"
  default     = "LM-igw"
}

variable "route_table" {
  type        = string
  description = "public_route-table_name"
  default     = "public_route-table"
}

variable "subnet-name1" {
  type    = string
  default = "public-subnet-1"
}

variable "subnet-name2" {
  type    = string
  default = "public-subnet-2"
}

variable "instance-1" {
  description = "instance name"
  type        = string
  default     = "ubuntu-dev-1"
}

variable "instance-2" {
  description = "instance name"
  type        = string
  default     = "ubuntu-dev-2"
}

variable "key_name" {
  description = " SSH keys to connect to ec2 instance"
  default     = "jenkins-server-key"
}

variable "load_balancer" {
  description = "Name of the load balancer"
  type        = string
  default     = "LM-load-balancer"
}

variable "load_balancer_type" {
  description = "type of the load balancer"
  type        = string
  default     = "application"
}

variable "target_gp" {
  description = "my target group"
  type        = string
  default     = "LM_target_group"
}