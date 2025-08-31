# Airflow EMR Redshift Data Transformation

## Propósito del Proyecto

Este proyecto implementa un pipeline de datos completo que procesa información de salarios utilizando Apache Spark en Amazon EMR, almacena los resultados en Amazon Redshift y orquesta todo el flujo mediante Apache Airflow (MWAA). El sistema automatiza la extracción, transformación y carga (ETL) de datos de salarios, generando análisis estadísticos y enviando reportes por correo electrónico.

## Características del Proyecto

- **Pipeline ETL automatizado** con Apache Spark en EMR
- **Orquestación de workflows** con Apache Airflow (MWAA)
- **Data Warehouse** en Amazon Redshift para análisis
- **Procesamiento distribuido** de datos con múltiples worker nodes
- **Reportes automatizados** por correo electrónico usando SES
- **Infraestructura como código** con Terraform
- **Arquitectura modular** con separación de responsabilidades
- **Gestión de staging tables** con estrategia swap para zero-downtime
- **Análisis de salarios** por experiencia, título de trabajo y geografía

## Prerrequisitos para el Despliegue

- **AWS CLI** configurado con credenciales apropiadas
- **Terraform** >= 1.0
- **Python** >= 3.8
- **Cuenta AWS** con permisos para crear recursos EMR, Redshift, MWAA, VPC, IAM
- **Par de claves EC2** para acceso a instancias

## Instrucciones de Despliegue

### 1. Configuración de Amazon SES

Antes del despliegue, crear credenciales SMTP en SES:

1. Acceda a la **consola de AWS** → **Amazon SES**
2. Verifique que esté en la región correcta (us-east-1)
3. En el menú lateral, seleccione **SMTP settings**
4. Haga clic en **Create SMTP credentials**
5. Ingrese un nombre para el usuario SMTP (ej: `ses-smtp-user`)
6. Haga clic en **Create User**
7. **IMPORTANTE**: Descargue y guarde las credenciales SMTP (usuario y contraseña)
8. Estas credenciales serán necesarias para el archivo `terraform.tfvars`

**Nota**: La verificación de identidades de correo se realizará automáticamente después del despliegue de Terraform. Recibirá correos de verificación que debe abrir para confirmar las identidades de origen y destino.

### 2. Crear Roles por Defecto de EMR

```bash
# Crear roles EMR_EC2_DefaultRole y EMR_DefaultRole
aws emr create-default-roles
```

**Referencia**: [AWS CLI EMR Create Default Roles](https://docs.aws.amazon.com/cli/latest/reference/emr/create-default-roles.html)

### 3. Crear Key Pair para EC2

1. Acceda a la **consola de AWS** → **EC2** → **Key Pairs**
2. Haga clic en **Create key pair**
3. Ingrese un nombre (ej: `my-keypair`)
4. Seleccione **RSA** y **.pem** format
5. Haga clic en **Create key pair**
6. Guarde el archivo `.pem` descargado en un lugar seguro
7. En sistemas Unix/Linux: `chmod 400 nombre-keypair.pem`

### 4. Configurar Variables de Terraform

Crear archivo `terraform/terraform.tfvars` con todas las variables necesarias:

```hcl
# terraform.tfvars
vpc_region = "us-east-1"
vpc_cidr = "10.0"
availability_zone = "us-east-1a"
environment_name = "[environment-name]"
redshift_cluster_name = "[cluster-name]"
redshift_db_name = "[database-name]"
redshift_db_user = "[db-username]"
redshift_db_password = "[secure-password]"
ses_email_origin = "[origin-email]"
ses_email_destination = "[destination-email]"
smtp_user = "[smtp-username-from-step-1]"
smtp_password = "[smtp-password-from-step-1]"
bastion_instance_type = "t3.micro"
redshift_node_type = "ra3.large"
redshift_cluster_type = "single-node"
airflow_environment_class = "mw1.micro"
airflow_version = "2.10.3"
airflow_access_mode = "PUBLIC_ONLY"
dag_local_path = "[path-to-dags-folder]"
mwaa_requirements_local_path = "[path-to-requirements.txt]"
etl_file_local_path = "[path-to-etl.py]"
input_csv_local_path = "[path-to-salaries.csv]"
key_pair_identifier = "[your-keypair-name]"
```

### 5. Desplegar Infraestructura

```bash
# Inicializar Terraform
terraform init

# Planificar despliegue
terraform plan

# Aplicar cambios
terraform apply
```

### 6. Verificar Identidades de Correo en SES

Después del despliegue de Terraform, verificar las identidades de correo:

1. Revise la bandeja de entrada de los correos configurados en `ses_email_origin` y `ses_email_destination`
2. Encontrará correos de **Amazon Web Services** con asunto "Amazon SES Email Address Verification Request"
3. **Abra cada correo** y haga clic en el enlace de verificación contenido
4. Confirme la verificación en la página web que se abre
5. Repita el proceso para ambos correos (origen y destino)

**Nota**: Este paso es esencial si SES está en modo Sandbox. Sin la verificación, no podrá enviar correos electrónicos.

### 7. Crear Tablas en Redshift

Después del despliegue, conectarse a Redshift para crear las tablas. Puede usar:

**Opción recomendada**: **Redshift Query Editor v2** (desde consola AWS)
- Acceda a **AWS Console** → **Amazon Redshift** → **Query Editor v2**
- Conecte usando las credenciales configuradas

**Opción alternativa**: Cliente local a través del **bastion host** desplegado
- Use herramientas como DBeaver, pgAdmin, o psql
- Conecte vía túnel SSH usando el bastion host

Ejecute el siguiente script SQL:

```sql
CREATE TABLE public.average_salary_by_experience (
    experience_level VARCHAR(10),
    average_salary_usd DOUBLE PRECISION
);

CREATE TABLE public.average_salary_by_job_title (
    job_title VARCHAR(255),
    average_salary_usd DOUBLE PRECISION
);

CREATE TABLE public.max_salary (
    max_salary_usd BIGINT,
    job_title VARCHAR(255)
);

CREATE TABLE public.min_salary (
    min_salary_usd BIGINT,
    job_title VARCHAR(255)
);

CREATE TABLE public.top_salaries (
    salary_usd BIGINT,
    job_title VARCHAR(255),
    experience_level VARCHAR(10),
    company_country VARCHAR(10)
);
```

### 8. Acceder al UI de MWAA

1. Acceda a la **consola de AWS** → **Amazon MWAA**
2. Seleccione su ambiente (ej: `bigdata-environment`)
3. Haga clic en **Open Airflow UI**
4. Acceda al menú **Admin** → **Variables** y **Admin** → **Connections**

### 9. Configurar Conexiones en MWAA

Crear la conexión `redshift_conn`:
- **Connection Type**: Postgres
- **Host**: [endpoint del cluster Redshift]
- **Database**: [database]
- **Login**: [username]
- **Password**: [password]
- **Port**: 5439

**Nota**: Para Host verificar salida "redshift_cluster_endpoint" de Terraform, ingrese el valor sin el puerto (:5439).

### 10. Configurar variables en MWAA

Crear las siguientes variables:
- **REGION**: [region]
- **ACCOUNT_ID**: [tu id de cuenta AWS]
- **EMR_SUBNET_ID**: [id de la subred para el cluster EMR]
- **EMR_KEY_NAME**: [nombre del key pair]
- **EMR_INSTANCE_TYPE**: [tamaño de instancias para EMR]
- **REDSHIFT_CLUSTER_ID**: [nombre del cluster de Redshift]
- **EMAIL**: [correo de destino para reportes]

**Nota**:
- Para EMR_SUBNET_ID verificar salida "emr_private_a" o "emr_private_b" de Terraform, cualquiera de los dos valores es válido.
- Para REDSHIFT_CLUSTER_ID verificar salida "redshift_cluster_id" de Terraform.
- Los demás valores deben coincidir con los valores asignados a Terraform.

## Estructura del Proyecto

```
airflow-emr-redshift-data-transformation/
├── terraform/
│   ├── modules/
│   │   ├── vpc/                    # Configuración de red
│   │   ├── iam/                    # Roles y políticas IAM
│   │   ├── buckets/                # Buckets S3
│   │   ├── redshift/               # Cluster Redshift
│   │   ├── mwaa/                   # Ambiente Airflow
│   │   ├── instances/              # Instancias EC2 (bastion)
│   │   ├── security_groups/        # Grupos de seguridad
│   │   └── ses/                    # Configuración SES
│   ├── main.tf                     # Configuración principal
│   ├── variables.tf                # Definición de variables
│   ├── outputs.tf                  # Outputs del despliegue
│   └── terraform.tfvars            # Valores de variables (no versionado)
├── dags/
│   └── etl.py                      # DAG principal ETL
├── etl/
│   └── etl.py                      # Script principal de ETL
├── data/
│   └── salaries.csv                # Datos de entrada
├── requirements/
│   └── requirements.txt            # Dependencias de MWAA
├── docs/
│   └── architecture.drawio         # Diagrama de arquitectura
├── .gitignore                      # Archivos excluidos de Git
└── README.md                       # Este archivo
```

## Esquema de Base de Datos

### Tablas en Redshift

| Tabla | Descripción | Columnas |
|-------|-------------|----------|
| `average_salary_by_experience` | Salarios promedio por nivel de experiencia | experience_level, average_salary_usd |
| `average_salary_by_job_title` | Salarios promedio por título de trabajo | job_title, average_salary_usd |
| `max_salary` | Salario máximo encontrado | max_salary_usd, job_title |
| `min_salary` | Salario mínimo encontrado | min_salary_usd, job_title |
| `top_salaries` | Top 10 salarios más altos | salary_usd, job_title, experience_level, company_country |

## Funcionamiento del DAG de MWAA

### Flujo Principal del Pipeline

El DAG principal (`etl.py`) ejecuta un pipeline completo de datos que incluye:

#### **1. Fase de Procesamiento EMR**
- **Crear Cluster EMR**: Despliega un cluster con 1 nodo master y 2 worker nodes
- **Agregar Step Spark**: Ejecuta el script ETL (`etl.py`) desde S3 usando `spark-submit`
- **Monitorear Ejecución**: Sensor que espera la finalización del job Spark
- **Terminar Cluster**: Limpia recursos EMR automáticamente

#### **2. Fase de Gestión Redshift**
- **Reanudar Cluster**: Activa el cluster Redshift si está pausado
- **Esperar Disponibilidad**: Sensor que confirma que Redshift está listo
- **Crear Staging Tables**: Genera tablas temporales para carga de datos
- **Cargar Datos**: Ejecuta comandos COPY desde S3 hacia staging tables
- **Intercambio de Tablas**: Estrategia swap para actualización sin downtime

#### **3. Fase de Reportes**
- **Procesar Resultados**: Extrae datos de múltiples tablas usando PostgresHook
- **Generar HTML**: Convierte resultados en formato HTML para email
- **Enviar Reporte**: Distribuye análisis por correo electrónico vía SES
- **Pausar Cluster**: Optimiza costos pausando Redshift

### Estrategia de Staging y Swap

El DAG implementa una estrategia de **zero-downtime deployment**:

1. **Staging Tables**: Se crean tablas temporales (`*_staging`)
2. **Carga Paralela**: Los datos se cargan en staging sin afectar producción
3. **Swap Atómico**: Las tablas se intercambian en una sola transacción
4. **Limpieza**: Las tablas antiguas se eliminan automáticamente

### Paralelización y Dependencias

```
[EMR Cluster Creation] ──┐
                         ├── [Spark Job] ── [EMR Termination]
[Redshift Resume] ───────┘                        │
                                                   ▼
[Staging Creation] ── [Data Loading] ── [Table Swap] ── [Reporting] ── [Redshift Pause]
```

### Gestión de Errores

- **EMR Steps**: Configurados con `TERMINATE_JOB_FLOW` para limpieza automática
- **Redshift Operations**: Transacciones atómicas para consistencia de datos
- **Trigger Rules**: `all_done` asegura limpieza de recursos incluso en fallos
- **Timeouts**: Sensores con límites de tiempo para evitar ejecuciones indefinidas

### Variables Dinámicas

El DAG utiliza **Variables de Airflow** para configuración flexible:
- Identificadores de recursos AWS (subnets, clusters, keys)
- Configuración de instancias EMR
- Credenciales y endpoints de servicios
- Rutas de archivos y buckets S3

## Tecnologías Utilizadas

- **Apache Airflow (MWAA)** - Orquestación de workflows
- **Apache Spark** - Procesamiento distribuido de datos
- **Amazon EMR** - Plataforma de big data gestionada
- **Amazon Redshift** - Data warehouse
- **Amazon S3** - Almacenamiento de objetos
- **Terraform** - Infraestructura como código
- **Python** - Lenguaje de programación principal
- **PySpark** - API de Python para Spark
- **Pandas** - Manipulación de datos
- **Amazon SES** - Servicio de correo electrónico
- **Amazon VPC** - Red privada virtual
- **AWS IAM** - Gestión de identidades y accesos

## Notas Importantes

### Seguridad
- Las credenciales sensibles deben configurarse como variables de Airflow, no hardcodeadas
- El archivo `terraform.tfvars` contiene información sensible y no debe versionarse
- Los buckets S3 tienen cifrado habilitado por defecto
- Las subnets privadas no tienen acceso directo a internet

### Costos
- El cluster Redshift se puede pausar cuando no esté en uso para reducir costos
- Las instancias EMR se terminan automáticamente después de completar los jobs
- MWAA cobra por tiempo de ejecución y número de workers

### Monitoreo
- Los logs de Airflow están disponibles en CloudWatch
- Los logs de EMR se almacenan en S3
- Redshift tiene métricas disponibles en CloudWatch

### Limitaciones
- SES en modo Sandbox solo permite envío a emails verificados
- El cluster EMR requiere al menos 2 nodos para procesamiento distribuido
- Redshift single-node tiene limitaciones de escalabilidad

### Troubleshooting
- Verificar que los roles EMR tengan permisos adecuados para S3
- Confirmar que las subnets tengan conectividad a internet via NAT Gateway
- Validar que las security groups permitan el tráfico necesario
- Revisar logs en CloudWatch para errores específicos