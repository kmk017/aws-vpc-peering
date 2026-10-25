variable "aws_region" {
  description = "AWS region for the lab"
  type        = string
  default     = "ap-south-1"
}

variable "student_name" {
  description = "Student name used in resource tags"
  type        = string
  default     = "Mohan Kumar K"
}

variable "student_public_ip" {
  description = "Your current public IPv4 address, without /32"
  type        = string

  validation {
    condition     = can(cidrhost("${var.student_public_ip}/32", 0))
    error_message = "student_public_ip must be a valid IPv4 address without a CIDR suffix."
  }
}

variable "instance_type" {
  description = "EC2 instance type; check current regional pricing and account eligibility"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair in the selected region"
  type        = string
  default     = "ewb-lab"
}

variable "enable_peering_routes" {
  description = "Set false only when intentionally demonstrating the pre-route baseline failure"
  type        = bool
  default     = true
}
