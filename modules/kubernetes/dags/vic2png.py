"""
VIC to PNG Conversion DAG
Converts VIC format images to PNG format
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.dummy import DummyOperator

default_args = {
    'owner': 'unity-sps',
    'depends_on_past': False,
    'start_date': datetime(2025, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'vic2png',
    default_args=default_args,
    description='VIC to PNG Conversion Pipeline',
    schedule_interval=None,  # Manual triggers only
    catchup=False,
    tags=['image-processing', 'conversion', 'unity-sps'],
)

def validate_input(**context):
    """Validate input VIC files"""
    print("Validating input VIC files...")
    # Add your validation logic here
    return "input_validated"

def convert_vic_to_png(**context):
    """Convert VIC files to PNG format"""
    print("Converting VIC files to PNG...")
    # Add your conversion logic here
    return "conversion_completed"

def validate_output(**context):
    """Validate converted PNG files"""
    print("Validating converted PNG files...")
    # Add your output validation logic here
    return "output_validated"

def cleanup_temp_files(**context):
    """Clean up temporary files"""
    print("Cleaning up temporary files...")
    # Add your cleanup logic here
    return "cleanup_completed"

# Define tasks
validate_input_task = PythonOperator(
    task_id='validate_input',
    python_callable=validate_input,
    dag=dag,
)

convert_task = PythonOperator(
    task_id='convert_vic_to_png',
    python_callable=convert_vic_to_png,
    dag=dag,
)

validate_output_task = PythonOperator(
    task_id='validate_output',
    python_callable=validate_output,
    dag=dag,
)

cleanup_task = PythonOperator(
    task_id='cleanup_temp_files',
    python_callable=cleanup_temp_files,
    dag=dag,
)

# Define task dependencies
validate_input_task >> convert_task >> validate_output_task >> cleanup_task
