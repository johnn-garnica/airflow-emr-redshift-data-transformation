output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "subnet_ids" {
  value = module.vpc.subnet_ids
}

output "security_group_ids" {
  value = module.security_groups.security_group_ids
}

output "bastion_host_info" {
  value = module.instances.bastion_host_info
}

output "bucket_ids" {
  value = module.buckets.buckets_info
}

output "roles_policies_arn" {
  value = module.iam.roles_policies_arn
}

output "mwaa_environment_info" {
  value = module.mwaa.mwaa_environment_info
}

output "redshift_cluster_info" {
  value = module.redshift.redshift_cluster_info
}