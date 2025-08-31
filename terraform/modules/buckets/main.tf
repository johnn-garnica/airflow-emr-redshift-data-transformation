######EMR S3 BUCKET######
resource "aws_s3_bucket" "emr_data_bucket" {
  bucket = "emr-data-bucket-${var.vpc_region}-${var.account_id}"
  region = var.vpc_region

  tags = {
    Name = "EMR bucket"
  }
}

resource "aws_s3_bucket_versioning" "versioning_emr_data_bucket" {
  bucket = aws_s3_bucket.emr_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [ aws_s3_bucket.emr_data_bucket ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "emr_data_bucket_sse" {
  bucket = aws_s3_bucket.emr_data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  depends_on = [ aws_s3_bucket.emr_data_bucket ]
}

resource "aws_s3_object" "emr_input_folder" {
  bucket  = aws_s3_bucket.emr_data_bucket.id
  key     = "input/"         
  content = ""    

  depends_on = [ aws_s3_bucket.emr_data_bucket ]          
}

resource "aws_s3_object" "emr_output_folder" {
  bucket  = aws_s3_bucket.emr_data_bucket.id
  key     = "output/"         
  content = ""  

  depends_on = [ aws_s3_bucket.emr_data_bucket ]           
}

resource "aws_s3_object" "emr_logs_folder" {
  bucket  = aws_s3_bucket.emr_data_bucket.id
  key     = "logs/"         
  content = ""      
  depends_on = [ aws_s3_bucket.emr_data_bucket ]        
}

resource "aws_s3_object" "emr_scrips_folder" {
  bucket  = aws_s3_bucket.emr_data_bucket.id
  key     = "scripts/"         
  content = ""      
  depends_on = [ aws_s3_bucket.emr_data_bucket ]        
}

resource "aws_s3_object" "emr_csv_file" {
  bucket = aws_s3_bucket.emr_data_bucket.id
  key    = "input/salaries.csv"
  source = var.input_csv_local_path
  etag = filemd5(var.input_csv_local_path)

  depends_on = [ aws_s3_bucket.emr_data_bucket ]
}

resource "aws_s3_object" "emr_script_file" {
  bucket = aws_s3_bucket.emr_data_bucket.id
  key    = "scripts/etl.py"
  source = var.etl_file_local_path
  etag = filemd5(var.etl_file_local_path)

  depends_on = [ aws_s3_bucket.emr_data_bucket ]
}

######MWAA S3 BUCKET######
resource "aws_s3_bucket" "mwaa_data_bucket" {
  bucket = "mwaa-data-bucket-${var.vpc_region}-${var.account_id}"
  region = var.vpc_region

  tags = {
    Name = "MWAA bucket"
  }
}

resource "aws_s3_bucket_versioning" "versioning_mwaa_data_bucket" {
  bucket = aws_s3_bucket.mwaa_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [ aws_s3_bucket.mwaa_data_bucket ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mwaa_data_bucket_sse" {
  bucket = aws_s3_bucket.mwaa_data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  depends_on = [ aws_s3_bucket.mwaa_data_bucket ]
}

resource "aws_s3_object" "mwaa_dags_folder" {
  bucket  = aws_s3_bucket.mwaa_data_bucket.id
  key     = "dags/"         
  content = ""  

  depends_on = [ aws_s3_bucket.mwaa_data_bucket ]            
}

resource "aws_s3_object" "mwaa_plugins_folder" {
  bucket  = aws_s3_bucket.mwaa_data_bucket.id
  key     = "plugins/"         
  content = ""   

  depends_on = [ aws_s3_bucket.mwaa_data_bucket ]          
}

resource "aws_s3_object" "mwaa_requirements_folder" {
  bucket  = aws_s3_bucket.mwaa_data_bucket.id
  key     = "requirements/"         
  content = ""   

  depends_on = [ aws_s3_bucket.mwaa_data_bucket ]           
}

resource "aws_s3_object" "mwaa_requirements_file" {
  bucket = aws_s3_bucket.mwaa_data_bucket.id
  key    = "requirements/requirements.txt"
  source = var.mwaa_requirements_local_path
  etag = filemd5(var.mwaa_requirements_local_path)

  depends_on = [ aws_s3_bucket.mwaa_data_bucket ]
}

resource "aws_s3_object" "mwaa_DAG_file_1" {
  bucket = aws_s3_bucket.mwaa_data_bucket.id
  key    = "dags/etl.py"
  source = var.dag_local_path
  etag = filemd5(var.dag_local_path)

  depends_on = [ aws_s3_bucket.mwaa_data_bucket ]
}