resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "bigdata-redshift-subnet-group"
  subnet_ids = [var.redshift_private_a_subnet_id, var.redshift_private_b_subnet_id]
}

resource "aws_redshift_cluster" "redshift_cluster" {
  availability_zone  = var.availability_zone
  cluster_identifier = "${var.redshift_cluster_name}"
  database_name      = var.redshift_db_name
  master_username    = var.redshift_db_user
  master_password    = var.redshift_db_password
  node_type          = var.redshift_node_type
  cluster_type       = var.redshift_cluster_type
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnet_group.name
  vpc_security_group_ids = [var.ssh_security_group_id, var.redshift_security_group_id]
  iam_roles = [ var.redshift_role_s3 ]
  publicly_accessible = false
  skip_final_snapshot = true
}