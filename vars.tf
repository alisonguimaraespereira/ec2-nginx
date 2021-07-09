variable "name" {
  type        = string
  description = "Name  (e.g. `app` or `cluster`)"
  default      = "nginxapp"
}
####Account Variable######
variable "aws_account_id" {
  description = "AWS Id Account"
  default = "ADICIONAR INFORMACAO"
}

variable "region" {
  description = "Region that will be used in AWS"
  default = "us-east-1"
}

variable "access" { 
  default = "ADICIONAR INFORMACAO"
  description = "access key aws account"
}

variable "secret" { 
  default = "ADICIONAR INFORMACAO"
  description = "access key aws account"
}

variable "vpc_id" {
  description = "Region that we're gonna use to create EC2"
  default = "ADICIONAR INFORMACAO"
}
variable "aws_region" {
  default = "us-east-1"
}
variable "zone_id" {
  default = ""
}

variable "ami_id" {
  description = "IAM"
  default = "ADICIONAR INFORMACAO"
}

variable "subnet_private_a" {
  default = "ADICIONAR INFORMACAO"
}

variable "subnet_private_b" {
  default = "ADICIONAR INFORMACAO"
}
###nginx###
variable "nginx_ec2_name" {
  description = "ec2 or Servername"
  default = "nginxapp"
}
variable "nginx_role_names" {
  description = "Policies used on IAM Role creation"
  type        = list(string)
  default     = ["AmazonS3ReadOnlyAccess", "IAMReadOnlyAccess", "AmazonEC2ReadOnlyAccess"] 
}

variable "nginx_instance_type" {
  description = "Instance Types or Instance Size"
  default = "t3.medium"
}

variable "aws_key_pair_name" {
  description = "Name Of Keypair displayed on AWS"
  default     = "ssh_key"
}

variable "nginx_target_group_name" {
  description = "Target Group Name"
  default = "nginx-linux-tg"
}

variable "nginx_target_group_port" {
  description = "Ports To map in Target Group, id began with 0"
  default = [80, 443]
}

variable "nginx_instance_count" {
  description = "Number of Instances"
  default = "2"
}
variable "nginx_root_volume_size" {
  description = "Root volume size in GB"
  default = "50"
}

variable "nginx_ebs_volume_size" {
  description = "EBS volume size in GB"
  default = "10"
}
###Universal###

variable "ip_sg_list_ec2" {
  default = ["0.0.0.0/0"]
}