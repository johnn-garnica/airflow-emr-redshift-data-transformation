resource "aws_mwaa_environment" "mwaa_environment" {
  region                = var.vpc_region
  airflow_version       = var.airflow_version
  environment_class     = var.airflow_environment_class
  dag_s3_path           = "dags/"
  requirements_s3_path  = "requirements/requirements.txt"
  execution_role_arn    = var.mwaa_role_arn
  name                  = "${var.mwaa_environment_name}"
  webserver_access_mode = var.airflow_access_mode

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "WARNING"
    }
    scheduler_logs {
      enabled   = true
      log_level = "WARNING"
    }
    task_logs {
      enabled   = true
      log_level = "INFO"
    }
    webserver_logs {
      enabled   = true
      log_level = "WARNING"
    }
    worker_logs {
      enabled   = true
      log_level = "WARNING"
    }
  }

  network_configuration {
    security_group_ids = [var.airflow_security_group_id]
    subnet_ids         = [var.airflow_private_a_subnet_id, var.airflow_private_b_subnet_id]
  }

  airflow_configuration_options = {
    "smtp.smtp_host"        = "email-smtp.${var.vpc_region}.amazonaws.com"
    "smtp.smtp_port"        = "587"
    "smtp.smtp_user"        = var.smtp_user
    "smtp.smtp_password"    = var.smtp_password
    "smtp.smtp_starttls"    = "True"
    "smtp.smtp_ssl"         = "False"
    "smtp.smtp_mail_from"   = var.ses_email_origin
  }

  source_bucket_arn = var.mwaa_data_bucket_arn

  tags = {
    Name        = "${var.mwaa_environment_name}"
  }
}