###nginx###
#output "nginx_name" {
#  value = "${module.aws_nginx_iam_role}"
#}

output "nginx_ec2_id" {
  description = "List of IDs of instances"
  value       = ["${module.nginx_ec2_instance.*.id}"]
}


output "dns_name" {
  value = ["${module.nginx_nlb.*.dns_name}"]
}
