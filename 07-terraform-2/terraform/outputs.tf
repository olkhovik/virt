output "yandex_zone" {
  value       = yandex_compute_instance.vm.zone
  description = "Регион Яндекса, в котором создан инстанс"
}

output "yandex_ip_private" {
  value       = yandex_compute_instance.vm.network_interface.0.ip_address
  description = "Приватный IP на Яндексе"
}

output "yandex_vpc_subnet" {
  value       = resource.yandex_vpc_subnet.subnet.id
  description = "Идентификатор подсети в которой создан инстанс"
}

output "aws_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS account ID"
}

output "aws_user_id" {
  value       = data.aws_caller_identity.current.user_id
  description = "AWS user ID"
}

output "aws_region" {
  value       = data.aws_region.current.endpoint
  description = "AWS регион, который используется в данный момен"
}

output "aws_net_private_ip" {
  value       = resource.aws_instance.ubuntu.private_ip
  description = "Приватный IP ec2 инстансы"
}

output "aws_net_subnet_id" {
  value       = resource.aws_instance.ubuntu.subnet_id
  description = "Идентификатор подсети в которой создан инстанс"
}