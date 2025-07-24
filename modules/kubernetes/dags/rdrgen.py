"""
RDR Generation DAG
Generates RDR (Raw Data Records) from input data
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
    'rdrgen',
    default_args=default_args,
    description='RDR Generation Pipeline',
    schedule_interval=None,  # Manual triggers only
    catchup=False,
    tags=['rdr', 'data-processing', 'unity-sps'],
)

def prep_data(**context):
    """Prepare data for RDR generation"""
    print("Preparing data for RDR generation...")
    # Add your data preparation logic here
    return "data_prepared"

def generate_rdr(**context):
    """Generate RDR from prepared data"""
    print("Generating RDR...")
    # Add your RDR generation logic here
    return "rdr_generated"

def post_process(**context):
    """Post-process generated RDR"""
    print("Post-processing RDR...")
    # Add your post-processing logic here
    return "rdr_post_processed"

# Define tasks
prep_task = PythonOperator(
    task_id='prep',
    python_callable=prep_data,
    dag=dag,
)

rdrgen_task = PythonOperator(
    task_id='rdrgen',
    python_callable=generate_rdr,
    dag=dag,
)

post_task = PythonOperator(
    task_id='post',
    python_callable=post_process,
    dag=dag,
)

# Define task dependencies
prep_task >> rdrgen_task >> post_task
