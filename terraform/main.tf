provider "aws" {
  region  = var.vpc_region
  profile = "jg"
}

module "vpc" {
  source = "./modules/vpc"
  vpc_region = var.vpc_region
  vpc_cidr = var.vpc_cidr
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
}

module "instances" {
  source = "./modules/instances"
  public_a_subnet_id = module.vpc.subnet_ids.public_a
  ssh_security_group_id = module.security_groups.security_group_ids.public_ssh
  availability_zone = var.availability_zone
  bastion_instance_type = var.bastion_instance_type
  key_pair_identifier = var.key_pair_identifier
}

module "buckets" {
  source = "./modules/buckets"
  vpc_region = var.vpc_region
  account_id = module.vpc.account_id
  dag_local_path = var.dag_local_path
  mwaa_requirements_local_path = var.mwaa_requirements_local_path
  etl_file_local_path = var.etl_file_local_path
  input_csv_local_path = var.input_csv_local_path
}

module "iam" {
  source = "./modules/iam"
  vpc_region = var.vpc_region
  account_id = module.vpc.account_id
  environment_name = var.environment_name
  redshift_cluster_name = var.redshift_cluster_name
  s3_bucket_name = module.buckets.buckets_info.mwaa_data_bucket_id
  redshift_s3_bucket_name = module.buckets.buckets_info.emr_data_bucket_id
}

module "mwaa" {
  source = "./modules/mwaa"
  vpc_region = var.vpc_region
  mwaa_role_arn = module.iam.roles_policies_arn.mwaa_role_arn
  mwaa_environment_name = var.environment_name
  airflow_environment_class = var.airflow_environment_class
  airflow_version = var.airflow_version
  airflow_access_mode = var.airflow_access_mode
  mwaa_data_bucket_arn = module.buckets.buckets_info.mwaa_data_bucket_arn
  airflow_private_a_subnet_id = module.vpc.subnet_ids.airflow_private_a
  airflow_private_b_subnet_id = module.vpc.subnet_ids.airflow_private_b
  ssh_security_group_id = module.security_groups.security_group_ids.public_ssh
  https_security_group_id = module.security_groups.security_group_ids.private_https
  airflow_security_group_id = module.security_groups.security_group_ids.mwaa_env
  smtp_user = var.smtp_user
  smtp_password = var.smtp_password
  ses_email_origin = var.ses_email_origin
}

module "redshift" {
  source = "./modules/redshift"
  vpc_region = var.vpc_region
  availability_zone = var.availability_zone
  redshift_cluster_name = var.redshift_cluster_name
  redshift_db_name = var.redshift_db_name
  redshift_db_user = var.redshift_db_user
  redshift_db_password = var.redshift_db_password
  redshift_node_type = var.redshift_node_type
  redshift_cluster_type = var.redshift_cluster_type
  ssh_security_group_id = module.security_groups.security_group_ids.private_ssh
  redshift_security_group_id = module.security_groups.security_group_ids.private_redshift
  redshift_private_a_subnet_id = module.vpc.subnet_ids.redshift_private_a
  redshift_private_b_subnet_id = module.vpc.subnet_ids.redshift_private_b
  redshift_role_s3 = module.iam.roles_policies_arn.redshift_role_arn
}

module "ses" {
  source = "./modules/ses"
  ses_email_origin = var.ses_email_origin
  ses_email_destination = var.ses_email_destination
  vpc_region = var.vpc_region
  account_id = module.vpc.account_id
}