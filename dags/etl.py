from datetime import datetime, timedelta
from airflow import DAG
from airflow.models import Variable
from airflow.providers.amazon.aws.operators.emr import (
    EmrCreateJobFlowOperator,
    EmrTerminateJobFlowOperator,
    EmrAddStepsOperator,
)
from airflow.providers.amazon.aws.operators.redshift_cluster import (
    RedshiftResumeClusterOperator,
    RedshiftPauseClusterOperator,
)
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.providers.amazon.aws.sensors.emr import EmrStepSensor
from airflow.providers.amazon.aws.sensors.redshift_cluster import RedshiftClusterSensor
from airflow.operators.python import PythonOperator
from airflow.operators.email import EmailOperator
import pandas as pd

REDSHIFT_CONN_ID = "redshift_conn"
REDSHIFT_CLUSER_ID = Variable.get("REDSHIFT_CLUSTER_ID")
REGION = Variable.get("REGION")
ACCOUNT_ID = Variable.get("ACCOUNT_ID")
BUCKET = f"emr-data-bucket-{REGION}-{ACCOUNT_ID}"
S3_OUTPUT_PATH = f"s3://{BUCKET}/output/"
IAM_ROLE = f"arn:aws:iam::{ACCOUNT_ID}:role/redshift-role-{REGION}-{ACCOUNT_ID}"
EMAIL = Variable.get("EMAIL")

TABLE_TARGET_1 = "public.average_salary_by_experience"
TABLE_STAGING_1 = "public.average_salary_by_experience_staging"

TABLE_TARGET_2 = "public.average_salary_by_job_title"
TABLE_STAGING_2 = "public.average_salary_by_job_title_staging"

TABLE_TARGET_3 = "public.max_salary"
TABLE_STAGING_3 = "public.max_salary_staging"

TABLE_TARGET_4 = "public.min_salary"
TABLE_STAGING_4 = "public.min_salary_staging"

TABLE_TARGET_5 = "public.top_salaries"
TABLE_STAGING_5 = "public.top_salaries_staging"

QUERIES = {
    "average_salary_by_experience": f"SELECT * FROM {TABLE_TARGET_1};",
    "average_salary_by_job_title": f"SELECT * FROM {TABLE_TARGET_2} LIMIT 10;",
    "max_salary": f"SELECT * FROM {TABLE_TARGET_3};",
    "min_salary": f"SELECT * FROM {TABLE_TARGET_4};",
    "top_salaries": f"SELECT * FROM {TABLE_TARGET_5};"
}

def process_results(**context):
    from airflow.providers.postgres.hooks.postgres import PostgresHook
    hook = PostgresHook(postgres_conn_id="redshift_conn")
    
    html_content = "<h1>Reporte de Salarios</h1>"
    
    for table_name, query in QUERIES.items():
        records = hook.get_records(query)
        if records:
            df = pd.DataFrame(records)
            html_content += f"<h2>{table_name.replace('_', ' ').title()}</h2>"
            html_content += df.to_html(index=False)
            html_content += "<br><br>"
    
    return html_content

SPARK_STEPS = [
    {
        "Name": "etl_job",
        "ActionOnFailure": "TERMINATE_JOB_FLOW",
        "HadoopJarStep": {
            "Jar": "command-runner.jar",
            "Args": ["spark-submit", "--deploy-mode", "cluster", f"s3://{BUCKET}/scripts/etl.py"],
        },
    }
]

JOB_FLOW_OVERRIDES = {
    "Name": "ETLCluster",
    "ReleaseLabel": "emr-7.1.0",
    "LogUri": f"s3://{BUCKET}/logs/",
    "Applications": [{"Name": "Spark"}],
    "Instances": {
        "Ec2SubnetId": Variable.get("EMR_SUBNET_ID"),
        "Ec2KeyName": Variable.get("EMR_KEY_NAME"),  
        "InstanceGroups": [
            {
                "Name": "Primary node",
                "Market": "ON_DEMAND",
                "InstanceRole": "MASTER",
                "InstanceType": Variable.get("EMR_INSTANCE_TYPE"),
                "InstanceCount": 1,
            },

            {
                "Name": "Worker nodes",
                "Market": "ON_DEMAND", 
                "InstanceRole": "CORE",
                "InstanceType": Variable.get("EMR_INSTANCE_TYPE"),
                "InstanceCount": 2,
            }
        ],
        "KeepJobFlowAliveWhenNoSteps": True,
        "TerminationProtected": False,
    },
    "JobFlowRole": "EMR_EC2_DefaultRole",   
    "ServiceRole": "EMR_DefaultRole",
}

default_args = {
    "owner": "john.garnica",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 0,
}

dag = DAG(
    dag_id="etl_job_emr_redshift",
    description="Procesamiento con EMR y carga de data en Redshift con staging + swap",
    default_args=default_args,
    start_date=datetime(2025, 8, 22),
    schedule_interval=None, 
    catchup=False,
    tags=["redshift", "emr", "overwrite"],
)

create_cluster = EmrCreateJobFlowOperator(
    task_id="create_emr_cluster",
    job_flow_overrides=JOB_FLOW_OVERRIDES,
    aws_conn_id="aws_default",
    dag=dag,
)

add_step = EmrAddStepsOperator(
    task_id="add_spark_step",
    job_flow_id="{{ task_instance.xcom_pull(task_ids='create_emr_cluster', key='return_value') }}",
    steps=SPARK_STEPS,
    aws_conn_id="aws_default",
    dag=dag,
)

step_sensor = EmrStepSensor(
    task_id="watch_step",
    job_flow_id="{{ task_instance.xcom_pull(task_ids='create_emr_cluster', key='return_value') }}",
    step_id="{{ task_instance.xcom_pull(task_ids='add_spark_step', key='return_value')[0] }}",
    aws_conn_id="aws_default",
    dag=dag,
)

terminate_cluster = EmrTerminateJobFlowOperator(
    task_id="terminate_emr_cluster",
    job_flow_id="{{ task_instance.xcom_pull(task_ids='create_emr_cluster', key='return_value') }}",
    aws_conn_id="aws_default",
    trigger_rule="all_done",
    dag=dag,
)

create_staging = PostgresOperator(
    task_id="create_staging",
    postgres_conn_id=REDSHIFT_CONN_ID,
    sql=f"""
    DROP TABLE IF EXISTS {TABLE_STAGING_1};
    CREATE TABLE {TABLE_STAGING_1} (LIKE {TABLE_TARGET_1});

    DROP TABLE IF EXISTS {TABLE_STAGING_2};
    CREATE TABLE {TABLE_STAGING_2} (LIKE {TABLE_TARGET_2});    

    DROP TABLE IF EXISTS {TABLE_STAGING_3};
    CREATE TABLE {TABLE_STAGING_3} (LIKE {TABLE_TARGET_3}); 

    DROP TABLE IF EXISTS {TABLE_STAGING_4};
    CREATE TABLE {TABLE_STAGING_4} (LIKE {TABLE_TARGET_4}); 

    DROP TABLE IF EXISTS {TABLE_STAGING_5};
    CREATE TABLE {TABLE_STAGING_5} (LIKE {TABLE_TARGET_5}); 
    """,
    dag=dag,
)

copy_to_staging = PostgresOperator(
    task_id="copy_to_staging",
    postgres_conn_id=REDSHIFT_CONN_ID,
    sql=f"""
    COPY {TABLE_STAGING_1}
    FROM '{S3_OUTPUT_PATH}average_salary_by_experience'
    IAM_ROLE '{IAM_ROLE}'
    FORMAT AS PARQUET;

    COPY {TABLE_STAGING_2}
    FROM '{S3_OUTPUT_PATH}average_salary_by_job_title'
    IAM_ROLE '{IAM_ROLE}'
    FORMAT AS PARQUET;

    COPY {TABLE_STAGING_3}
    FROM '{S3_OUTPUT_PATH}max_salary'
    IAM_ROLE '{IAM_ROLE}'
    FORMAT AS PARQUET;


    COPY {TABLE_STAGING_4}
    FROM '{S3_OUTPUT_PATH}min_salary'
    IAM_ROLE '{IAM_ROLE}'
    FORMAT AS PARQUET;


    COPY {TABLE_STAGING_5}
    FROM '{S3_OUTPUT_PATH}top_salaries'
    IAM_ROLE '{IAM_ROLE}'
    FORMAT AS PARQUET;
    """,
    dag=dag,
)

swap_tables = PostgresOperator(
    task_id="swap_tables",
    postgres_conn_id=REDSHIFT_CONN_ID,
    sql=f"""
    BEGIN;
        -- Tabla 1
        DROP TABLE IF EXISTS {TABLE_TARGET_1}_old;
        ALTER TABLE {TABLE_TARGET_1} RENAME TO {TABLE_TARGET_1.split('.')[-1]}_old;
        ALTER TABLE {TABLE_STAGING_1} RENAME TO {TABLE_TARGET_1.split('.')[-1]};
        DROP TABLE {TABLE_TARGET_1.split('.')[-1]}_old;
        
        -- Tabla 2
        DROP TABLE IF EXISTS {TABLE_TARGET_2}_old;
        ALTER TABLE {TABLE_TARGET_2} RENAME TO {TABLE_TARGET_2.split('.')[-1]}_old;
        ALTER TABLE {TABLE_STAGING_2} RENAME TO {TABLE_TARGET_2.split('.')[-1]};
        DROP TABLE {TABLE_TARGET_2.split('.')[-1]}_old;

        -- Tabla 3
        DROP TABLE IF EXISTS {TABLE_TARGET_3}_old;
        ALTER TABLE {TABLE_TARGET_3} RENAME TO {TABLE_TARGET_3.split('.')[-1]}_old;
        ALTER TABLE {TABLE_STAGING_3} RENAME TO {TABLE_TARGET_3.split('.')[-1]};
        DROP TABLE {TABLE_TARGET_3.split('.')[-1]}_old;

        -- Tabla 4
        DROP TABLE IF EXISTS {TABLE_TARGET_4}_old;
        ALTER TABLE {TABLE_TARGET_4} RENAME TO {TABLE_TARGET_4.split('.')[-1]}_old;
        ALTER TABLE {TABLE_STAGING_4} RENAME TO {TABLE_TARGET_4.split('.')[-1]};
        DROP TABLE {TABLE_TARGET_4.split('.')[-1]}_old;

        -- Tabla 5
        DROP TABLE IF EXISTS {TABLE_TARGET_5}_old;
        ALTER TABLE {TABLE_TARGET_5} RENAME TO {TABLE_TARGET_5.split('.')[-1]}_old;
        ALTER TABLE {TABLE_STAGING_5} RENAME TO {TABLE_TARGET_5.split('.')[-1]};
        DROP TABLE {TABLE_TARGET_5.split('.')[-1]}_old;
    COMMIT;
    """,
    dag=dag,
)

resume_cluster = RedshiftResumeClusterOperator(
    task_id="resume_cluster",
    cluster_identifier=REDSHIFT_CLUSER_ID,  
    aws_conn_id="aws_default", 
    dag=dag,
)

wait_for_cluster = RedshiftClusterSensor(
    task_id="wait_for_cluster_available",
    cluster_identifier=REDSHIFT_CLUSER_ID,
    target_status="available",
    aws_conn_id="aws_default",
    poke_interval=30,
    timeout=600,
    dag=dag,
)

pause_cluster = RedshiftPauseClusterOperator(
    task_id="pause_cluster",
    cluster_identifier=REDSHIFT_CLUSER_ID,
    aws_conn_id="aws_default",
    dag=dag,
)

query_redshift = PythonOperator(
    task_id="process_results",
    python_callable=process_results,
    dag=dag,
)

send_email = EmailOperator(
    task_id="send_email",
    to=[EMAIL],
    subject="Resultados de análisis de salarios",
    html_content="{{ ti.xcom_pull(task_ids='process_results') }}",
    dag=dag,
)

[create_cluster, resume_cluster] >> add_step >> [step_sensor, wait_for_cluster] >> terminate_cluster >> create_staging >> copy_to_staging >> swap_tables >> query_redshift >> send_email >> pause_cluster