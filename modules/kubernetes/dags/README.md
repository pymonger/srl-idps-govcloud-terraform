# Airflow DAGs

This directory contains the default DAGs that will be automatically deployed to Airflow when the Terraform configuration is applied.

## Default DAGs

The following DAGs are included by default:

- **rdrgen.py** - RDR (Raw Data Records) Generation Pipeline
- **edrgen.py** - EDR (Event Data Records) Generation Pipeline
- **vic2png.py** - VIC to PNG Image Conversion Pipeline

## DAG Structure

Each DAG follows a consistent structure:

1. **Default Arguments** - Standard Airflow configuration
2. **DAG Definition** - DAG metadata and scheduling
3. **Task Functions** - Python functions for each task
4. **Task Operators** - Airflow operators for task execution
5. **Task Dependencies** - Workflow definition

## Customization

### Adding New DAGs

1. Create a new Python file in this directory (e.g., `my_dag.py`)
2. Follow the existing DAG structure pattern
3. Update the ConfigMap in `modules/kubernetes/main.tf` to include your new DAG:

```hcl
data = {
  "rdrgen.py"  = file("${path.module}/dags/rdrgen.py")
  "edrgen.py"  = file("${path.module}/dags/edrgen.py")
  "vic2png.py" = file("${path.module}/dags/vic2png.py")
  "my_dag.py"  = file("${path.module}/dags/my_dag.py")  # Add your new DAG
}
```

### Modifying Existing DAGs

Simply edit the Python files in this directory. The changes will be applied when you run `terraform apply`.

### Disabling DAG Deployment

To disable automatic DAG deployment, set the `deploy_dags` variable to `false`:

```hcl
deploy_dags = false
```

## DAG Configuration

### Scheduling

All default DAGs are configured for manual triggers only (`schedule_interval = None`). To enable automatic scheduling, modify the DAG definition:

```python
dag = DAG(
    'my_dag',
    default_args=default_args,
    description='My DAG Description',
    schedule_interval='0 2 * * *',  # Daily at 2 AM
    catchup=False,
    tags=['my-tag'],
)
```

### Task Configuration

Each task can be customized with:

- **Retries** - Configure retry behavior
- **Timeout** - Set task timeouts
- **Resources** - Define CPU/memory requirements
- **Dependencies** - Set up task relationships

## Deployment Process

1. **Terraform Apply** - DAGs are deployed as Kubernetes ConfigMaps
2. **Airflow Mount** - ConfigMaps are mounted to Airflow pods
3. **DAG Discovery** - Airflow automatically discovers and loads DAGs
4. **Validation** - DAGs are validated and made available in the UI

## Troubleshooting

### DAGs Not Appearing

1. Check if `deploy_dags = true` in your Terraform configuration
2. Verify the ConfigMap was created: `kubectl get configmap -n sps airflow-dag-configmaps`
3. Check Airflow logs: `kubectl logs -n sps deployment/airflow-webserver`

### DAG Syntax Errors

1. Check DAG syntax: `kubectl exec -n sps deployment/airflow-dag-processor -- python -m py_compile /opt/airflow/dags/your_dag.py`
2. Review Airflow dag-processor logs for specific error messages

### Updating DAGs

After modifying DAG files, run `terraform apply` to update the ConfigMap. Airflow will automatically reload the DAGs within the configured `dag_dir_list_interval` (default: 10 seconds).

## Best Practices

1. **Version Control** - Keep DAG files in version control
2. **Testing** - Test DAGs locally before deployment
3. **Documentation** - Document DAG purpose and dependencies
4. **Monitoring** - Set up alerts for DAG failures
5. **Resource Management** - Configure appropriate resource limits
