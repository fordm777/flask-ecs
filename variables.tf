## variables.tf

variable "force_image_rebuild" {
  type    = bool
  default = false
}

variable "app_name" {
  description = "Application Name"
  type        = string
}

variable "app_port" {
  description = "Application Container Port"
  type        = number
}

variable "image_tag" {
  description = "Image Tag for Docker image in ECR"
  type        = string
}

variable "aws_account" {
  description = "AWS Account Number"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "aws_profile" {
  description = "AWS Profile to Connect to AWS"
  type        = string
}

variable "aws_cdir" {
  description = "CDIR Range for the VPC"
  type        = string
}

variable "aws_private_subnets" {
  description = "Private Subnet CDIR Range"
  type        = list(string)
}

variable "aws_public_subnets" {
  description = "Public Subnet CDIR Range"
  type        = list(string)
}

variable "aws_enable_nat" {
  description = "Enable the NAT Gateway?"
  type        = bool
}

variable "fargate_cpu" {
  description = "CPU Size for Fargate process"
  type        = number
  default     = 256
}

variable "fargate_memory" {
  description = "Memory Size for Fargate process"
  type        = number
  default     = 512
}

variable "fargate_desired_count" {
  description = "Desired count of services"
  type        = number
  default     = 1
}

