variable "region" {
  type        = string
  description = "AWS deployment region"
  default     = "ap-south-1"
}

variable "az_a" {
  type        = string
  description = "First availability zone"
  default     = "ap-south-1a"
}

variable "az_b" {
  type        = string
  description = "Second availability zone"
  default     = "ap-south-1b"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  type        = string
  description = "CIDR for public subnet 1"
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  type        = string
  description = "CIDR for public subnet 2"
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  type        = string
  description = "CIDR for private subnet 1"
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  type        = string
  description = "CIDR for private subnet 2"
  default     = "10.0.4.0/24"
}

variable "app_port" {
  type        = number
  description = "Port the Flask app runs on"
  default     = 8080
}

variable "db_port" {
  type        = number
  description = "Database port"
  default     = 3306
}

variable "db_allocated_storage" {
  type        = number
  description = "Allocated storage for RDS in GB"
  default     = 20
}

variable "db_engine_version" {
  type        = string
  description = "MySQL engine version"
  default     = "8.0"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "db_name" {
  type        = string
  description = "Name of the initial database"
  default     = "main_db"
}

variable "db_username" {
  type        = string
  description = "Master username for RDS"
  default     = "admin"
}

variable "ec2_ami" {
  type        = string
  description = "AMI ID for the EC2 instance"
  default     = "ami-090d68841c2a28756"
}

variable "instance_type" {
  type        = string
  description = "Instance type for EC2"
  default     = "t3.micro"
}

variable "asg_min_size" {
  type        = number
  description = "Minimum number of instances in ASG"
  default     = 2
}

variable "asg_max_size" {
  type        = number
  description = "Maximum number of instances in ASG"
  default     = 4
}

variable "asg_desired_capacity" {
  type        = number
  description = "Desired number of instances in ASG"
  default     = 2
}

variable "asg_cpu_target" {
  type        = number
  description = "Target average CPU utilization percentage for ASG scaling"
  default     = 70.0
}