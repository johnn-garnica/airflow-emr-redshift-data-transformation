from pyspark.sql import SparkSession
from pyspark.sql.functions import col, trim, lower, year, current_date, when, avg

spark = SparkSession.builder \
    .appName("Jobs ETL") \
    .getOrCreate()

region = "us-east-1"
account_id = "730335453084"
bucket = f"emr-data-bucket-{region}-{account_id}"
s3_input_path = f"s3://{bucket}/input/salaries.csv"
s3_output_path = f"s3://{bucket}/output"

df = spark.read.csv(s3_input_path, header=True, inferSchema=True, sep=",")

print("Data loaded successfully.")

# DATA CLEANING
# Drop rows with any null values in the specified columns
df = df.dropna(subset=["work_year", "experience_level", "employment_type", "job_title", "salary_in_usd", "remote_ratio"], how='any')

# Replace null values in 'salary' with 0
df = df.fillna(0, subset=["salary"])

# Replace null values in specified columns with "unknown"
df = df.fillna("unknown", subset=["salary_currency", "employee_residence", "company_location", "company_size"])

# Convert 'job_title' to lowercase
df = df.withColumn("job_title", lower(col("job_title")))

# Trim whitespace from specified columns
cols = ["experience_level", "employment_type", "job_title", "salary_currency", "employee_residence", "company_size"]
for col_name in cols:
    df = df.withColumn(col_name, trim(col(col_name)))

print("Data cleaning completed.")

## DATA INTEGRITY VALIDATION
# Define valid values for filtering
valid_exp_levels = ["EN", "MI", "SE", "EX"]
valid_emp_types = ["FT", "PT", "CT", "FL"]
valid_remote_ratios = [0, 50, 100]
valid_company_sizes = ["S", "M", "L", "unknown"]

# Filter the DataFrame based on valid values
df = df.filter(
    col("experience_level").isin(valid_exp_levels) &
    col("employment_type").isin(valid_emp_types) &
    col("remote_ratio").isin(valid_remote_ratios) &
    col("company_size").isin(valid_company_sizes)
)

# Ensure salary is greater than 0, delete rows where salary is 0 or negative
df = df.filter(col("salary") > 0)

# Ensure salary_usd is greater than 0, delete rows where salary_usd is 0 or negative
df = df.filter(col("salary_in_usd") > 0)

# Ensure work_year is less than or equal to the current year, delete rows where work_year is in the future
df = df.filter(col("work_year") <= year(current_date()))

print("Data integrity validation completed.")

## DATA TRANSFORMATION
# Replace remote_ratio values with descriptive strings and drop the original column: OS = on-site, HY = hybrid, RM = remote
df = df.withColumn("work_mode", 
    when(col("remote_ratio") == 0, "OS")
    .when(col("remote_ratio") == 50, "HY") 
    .when(col("remote_ratio") == 100, "RM")) \
  .drop("remote_ratio")

# Rename columns for consistency
df = df.withColumnRenamed("salary_in_usd", "salary_usd") \
       .withColumnRenamed("employee_residence", "employee_country") \
       .withColumnRenamed("company_location", "company_country")

print("Data transformation completed.")

## DATA ANALYSIS
# Calculate average salary by experience level
avg_exp = df.groupBy("experience_level").agg(avg("salary_usd").alias("average_salary_usd"))

# Calculate average salary by job title
avg_job = df.groupBy("job_title").agg(avg("salary_usd").alias("average_salary_usd"))

# Get maximum salary and his associated job title
max_sal = df.orderBy(col("salary_usd").desc()).limit(1)
max_sal = max_sal.select("salary_usd", "job_title").withColumnRenamed("salary_usd", "max_salary_usd")

# Get minimum salary and his associated job title
min_sal = df.orderBy(col("salary_usd").asc()).limit(1)
min_sal = min_sal.select("salary_usd", "job_title").withColumnRenamed("salary_usd", "min_salary_usd")

# Get top 10 salaries with job title, experience level, and company country
top_sal = df.orderBy(col("salary_usd").desc()).limit(10)
top_sal = top_sal.select("salary_usd", "job_title", "experience_level", "company_country")

print("Data analysis completed.")

# # DATA WRITING
avg_exp.write.mode("overwrite").parquet(f"{s3_output_path}/average_salary_by_experience")
avg_job.write.mode("overwrite").parquet(f"{s3_output_path}/average_salary_by_job_title")
max_sal.write.mode("overwrite").parquet(f"{s3_output_path}/max_salary")
min_sal.write.mode("overwrite").parquet(f"{s3_output_path}/min_salary")
top_sal.write.mode("overwrite").parquet(f"{s3_output_path}/top_salaries")

print("Data writing completed.")

spark.stop()