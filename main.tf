provider "aws" {
  access_key = "${var.access}"
  secret_key = "${var.secret}"
  region = "${var.region}"
  profile = "default"

}
#terraform {
# backend "s3" {
# encrypt = true
# bucket = "terraform-tfstates"
# region = "us-east-1"
# key = "tfstate/nginx.tfstate"
# access_key = "vars/aws-account-env.yaml"
# secret_key = "vars/aws-account-env.yaml"
# }
#}


######nginx#####
###IAM ROLES####
#module "aws_nginx_iam_role" {
#  source                  = "git::https://github.com/guimaraesasp/terraform-modules.git//aws/iam/role/"
#  name                    = "RoleFor${var.nginx_ec2_name}"
#  aws_account_id          = "${var.aws_account_id}"
#  path_role               = "${data.template_file.nginx_role.rendered}"
#  policy_names            = "${var.nginx_role_names}"
#}

##data.json###
data "template_file" "nginx_role" {
  template = "${file("./role_nginx.json")}"
}

data "template_file" "userdata" {
  template = "${file("userdata/install_wizard.sh")}"
}
####SG####

module "aws_nginx_security_group_ec2" {

  source  = "git::https://github.com/guimaraesasp/terraform-modules.git//aws/security_group/create_sg/"
  sg_name = "${var.nginx_ec2_name}-sg"
  vpc_id  = var.vpc_id

}

####SGRULES####
module "nginx_sg_rule_22" {

  source            = "git::https://github.com/guimaraesasp/terraform-modules.git//aws/security_group/create_sg_rule/"
  port              = 22
  protocol          = "TCP"
  ips_sg_list       = var.ip_sg_list_ec2
  security_group_id = module.aws_nginx_security_group_ec2.id

}

module "nginx_sg_rule_port_80" {

  source            = "git::https://github.com/guimaraesasp/terraform-modules.git//aws/security_group/create_sg_rule/"
  port              = 80
  protocol          = "TCP"
  ips_sg_list       = var.ip_sg_list_ec2
  security_group_id = module.aws_nginx_security_group_ec2.id

}

module "nginx_sg_rule_port_443" {

  source            = "git::https://github.com/guimaraesasp/terraform-modules.git//aws/security_group/create_sg_rule/"
  port              = 443
  protocol          = "TCP"
  ips_sg_list       = var.ip_sg_list_ec2
  security_group_id = module.aws_nginx_security_group_ec2.id

}

####TG - Listenner - TGAttach - 0 ####

module "nginx_tg_0" {
  source              = "git::https://github.com/guimaraesasp/terraform-modules.git//aws/nlb/aws-lb-target-group"
  name                = "${var.nginx_target_group_name}-${element(var.nginx_target_group_port, 0)}"
  port                = element(var.nginx_target_group_port, 0)
  vpc_id              = var.vpc_id

}
module "nginx_listener_0" {
  source              = "git::https://github.com/guimaraesasp/terraform-modules.git//aws/nlb/aws-lb-listener"
  load_balancer_arn   = module.nginx_nlb.nlb_arn
  target_group_arn    = module.nginx_tg_0.nlb_tg_arn
  port                = element(var.nginx_target_group_port, 0)
}
module "nginx_tg-attachment_0" {
  source              = "git::https://github.com/guimaraesasp/terraform-modules.git//aws/nlb/aws-tg-attachment"
  target_group_arn    = "${module.nginx_tg_0.nlb_tg_arn}"
  target_ids          = module.nginx_ec2_instance.id

}
####TG - Listenner - TGAttach - 1 ####
module "nginx_tg_1" {
  source              = "git::https://github.com/guimaraesasp/terraform-modules.git//aws/nlb/aws-lb-target-group"
  name                = "${var.nginx_target_group_name}-${element(var.nginx_target_group_port, 1)}"
  port                = element(var.nginx_target_group_port, 1)
  vpc_id              = var.vpc_id

}
module "nginx_listener_1" {
  source              = "git::https://github.com/guimaraesasp/terraform-modules.git//aws/nlb/aws-lb-listener"
  load_balancer_arn   = module.nginx_nlb.nlb_arn
  target_group_arn    = module.nginx_tg_1.nlb_tg_arn
  port                = element(var.nginx_target_group_port, 1)
}
module "nginx_tg-attachment_1" {
  source              = "git::https://github.com/guimaraesasp/terraform-modules.git//aws/nlb/aws-tg-attachment"
  target_group_arn    = "${module.nginx_tg_1.nlb_tg_arn}"
  target_ids          = module.nginx_ec2_instance.id

}


####NLB####
module "nginx_nlb" {
  source              = "git::https://github.com/guimaraesasp/terraform-modules.git//aws/nlb/aws-lb"
  name                = "${var.nginx_ec2_name}-nlb"
  internal            = false
  #Sandbox
  external_subnets    = ["${var.subnet_private_a}", "${var.subnet_private_b}"]
  internal_subnets    = ["${var.subnet_private_a}", "${var.subnet_private_b}"]
}

resource "aws_key_pair" "ssh_key" {
  key_name    = "ssh_key"
  public_key  = "${file("/home/alison/.ssh/id_rsa_ansible.pub")}"
}

####ec2 Instance####

module "nginx_ec2_instance" {
  source                      = "git::https://github.com/guimaraesasp/terraform-modules.git//aws/ec2/"        
  instance_count              = var.nginx_instance_count
  name                        = var.nginx_ec2_name
  ami                         = var.ami_id
  instance_type               = var.nginx_instance_type 
  subnet_ids                  = ["${var.subnet_private_a}", "${var.subnet_private_b}"]
  vpc_security_group_ids      = [module.aws_nginx_security_group_ec2.id]
  associate_public_ip_address = true
  #iam_instance_profile        = "RoleFor${var.nginx_ec2_name}"
  user_data                   = "${data.template_file.userdata.rendered}"
  key_name                    = "${aws_key_pair.ssh_key.key_name}"

  root_block_device           = [
    {
      volume_type             = "gp2"
      volume_size             = var.nginx_root_volume_size
      encrypted               = true
    },
  ]

  ebs_block_device = [
    {
      device_name             = "/dev/sdf"
      volume_type             = "gp2"
      volume_size             = var.nginx_ebs_volume_size
      encrypted               = true
    }
  ]

  tags = {
    "Env"                     = var.nginx_ec2_name
    #"Location"                = var.env
    "servers"                 = "nginx"
  }
} 

