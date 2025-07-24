# KEDA Helm Release
resource "helm_release" "keda" {
  name             = "keda"
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  namespace        = "keda"
  create_namespace = true
  version          = "2.17.2"

  values = [
    yamlencode({
      image = {
        keda = {
          registry   = data.aws_caller_identity.current.account_id
          repository = "kedacore/keda"
          tag        = "2.17.2"
        }
        metricsApiServer = {
          registry   = data.aws_caller_identity.current.account_id
          repository = "kedacore/keda-metrics-apiserver"
          tag        = "2.17.2"
        }
        webhooks = {
          registry   = data.aws_caller_identity.current.account_id
          repository = "kedacore/keda-admission-webhooks"
          tag        = "2.17.2"
        }
        pullPolicy = "Always"
      }
      metricsServer = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }
      operator = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "512Mi"
          }
        }
      }
    })
  ]

  depends_on = [var.cluster_endpoint]
}

# Karpenter Helm Release
resource "helm_release" "karpenter" {
  name             = "karpenter"
  repository       = "https://charts.karpenter.sh"
  chart            = "karpenter"
  namespace        = "karpenter"
  create_namespace = true
  version          = "0.16.3"

  values = [
    yamlencode({
      replicas = 1
      settings = {
        clusterName       = var.cluster_name
        clusterEndpoint   = var.cluster_endpoint
        interruptionQueue = "${var.cluster_name}-karpenter"
        aws = {
          defaultInstanceProfile = "${var.cluster_name}-karpenter-node-instance-profile"
          enablePodENI           = false
        }
        hostNetwork = false
      }
      serviceAccount = {
        create = true
        name   = "karpenter"
        annotations = {
          "eks.amazonaws.com/role-arn" = var.karpenter_controller_role_arn
        }
      }
      nodeSelector = {
        "kubernetes.io/os" = "linux"
      }
      tolerations = [
        {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }
      ]
      resources = {
        requests = {
          cpu    = "1"
          memory = "1Gi"
        }
        limits = {
          cpu    = "1"
          memory = "1Gi"
        }
      }
      logLevel    = "info"
      logEncoding = "json"
      controller = {
        image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/karpenter/controller:v0.16.3"
        env = [
          {
            name  = "CLUSTER_NAME"
            value = var.cluster_name
          },
          {
            name  = "CLUSTER_ENDPOINT"
            value = var.cluster_endpoint
          },
          {
            name  = "AWS_REGION"
            value = data.aws_region.current.name
          }
        ]
        resources = {
          requests = {
            cpu    = "1"
            memory = "1Gi"
          }
          limits = {
            cpu    = "1"
            memory = "1Gi"
          }
        }
      }
      webhook = {
        image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/karpenter/webhook:v0.16.3"
        resources = {
          requests = {
            cpu    = "200m"
            memory = "100Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "100Mi"
          }
        }
      }
    })
  ]

  depends_on = [var.cluster_endpoint]
}

# Airflow Helm Release
resource "helm_release" "airflow" {
  name             = "airflow"
  repository       = "https://airflow.apache.org/charts"
  chart            = "airflow"
  namespace        = "sps"
  create_namespace = true
  version          = "1.17.0"

  values = [
    yamlencode({
      executor                 = "CeleryExecutor"
      airflowVersion           = "2.10.5"
      defaultAirflowRepository = "apache/airflow"
      migrateDatabase          = true

      images = {
        airflow = {
          repository = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/airflow"
          tag        = "2.10.5-python3.10"
        }
        pod_template = {
          repository = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/airflow"
          tag        = "2.10.5-python3.10"
        }
        statsd = {
          repository = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/statsd-exporter"
          tag        = "v0.28.0"
          pullPolicy = "IfNotPresent"
        }
        redis = {
          repository = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/redis"
          tag        = "7.2-bookworm"
          pullPolicy = "IfNotPresent"
        }
        gitSync = {
          repository = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/git-sync/git-sync"
          tag        = "v4.3.0"
          pullPolicy = "IfNotPresent"
        }
      }

      statsd = {
        enabled = true
      }

      workers = {
        replicas = 1
        resources = {
          requests = {
            cpu    = "500m"
            memory = "1Gi"
          }
          limits = {
            cpu    = "1500m"
            memory = "2Gi"
          }
        }
        keda = {
          enabled         = true
          minReplicaCount = 1
          maxReplicaCount = 10
          pollingInterval = 30
          cooldownPeriod  = 300
        }
        persistence = {
          enabled          = true
          size             = "100Gi"
          storageClassName = "gp2"
        }
        extraVolumes = [
          {
            name = "workers-volume"
            persistentVolumeClaim = {
              claimName = "shared-task-data-volume"
            }
          }
        ]
        extraVolumeMounts = [
          {
            name      = "workers-volume"
            mountPath = "/shared-task-data"
            readOnly  = false
          }
        ]
      }

      webserver = {
        resources = {
          requests = {
            cpu    = "500m"
            memory = "1Gi"
          }
          limits = {
            cpu    = "1000m"
            memory = "2Gi"
          }
        }
      }

      dagProcessor = {
        enabled = true
        resources = {
          requests = {
            cpu    = "500m"
            memory = "1Gi"
          }
          limits = {
            cpu    = "1000m"
            memory = "2Gi"
          }
        }
      }

      scheduler = {
        resources = {
          requests = {
            cpu    = "500m"
            memory = "1Gi"
          }
          limits = {
            cpu    = "1000m"
            memory = "2Gi"
          }
        }
      }

      postgresql = {
        enabled = true
        primary = {
          persistence = {
            enabled          = true
            size             = "50Gi"
            storageClassName = "gp2"
            accessMode       = "ReadWriteOnce"
          }
        }
        image = {
          registry   = data.aws_caller_identity.current.account_id
          repository = "postgresql"
          tag        = "16.1.0-debian-11-r15"
        }
        resources = {
          requests = {
            cpu    = "200m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "1"
            memory = "1Gi"
          }
        }
      }

      redis = {
        enabled = true
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
        persistence = {
          enabled          = true
          size             = "5Gi"
          storageClassName = "gp2"
        }
      }

      logs = {
        persistence = {
          enabled          = true
          size             = "5Gi"
          storageClassName = "efs-sc"
        }
      }

      config = {
        kubernetes = {
          namespace                   = "sps"
          worker_container_repository = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/airflow"
          worker_container_tag        = "2.10.5-python3.10"
          delete_worker_pods          = true
          run_as_user                 = 50000
        }
      }

      securityContext = {
        runAsUser = 50000
        fsGroup   = 50000
      }

      dags = {
        persistence = {
          enabled          = true
          size             = "5Gi"
          storageClassName = "efs-sc"
        }
      }

      env = [
        {
          name  = "AIRFLOW_VAR_KUBERNETES_PIPELINE_NAMESPACE"
          value = "sps"
        },
        {
          name  = "AIRFLOW_VAR_UNITY_PROJECT"
          value = "sps"
        },
        {
          name  = "AIRFLOW_VAR_UNITY_VENUE"
          value = "govcloud"
        },
        {
          name  = "AIRFLOW_VAR_UNITY_CLUSTER_NAME"
          value = var.cluster_name
        },
        {
          name  = "AIRFLOW_VAR_KARPENTER_NODE_POOLS"
          value = "default"
        },
        {
          name  = "AIRFLOW_VAR_ECR_URI"
          value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
        }
      ]

      extraEnv = [
        {
          name  = "AIRFLOW__CORE__DAGS_FOLDER"
          value = "/opt/airflow/dags"
        },
        {
          name  = "AIRFLOW__CORE__PLUGINS_FOLDER"
          value = "/opt/airflow/plugins"
        },
        {
          name  = "AIRFLOW__CORE__LAZY_LOAD_PLUGINS"
          value = "False"
        },
        {
          name  = "AIRFLOW__CORE__PARALLELISM"
          value = "32768"
        },
        {
          name  = "AIRFLOW__CORE__MAX_ACTIVE_RUNS_PER_DAG"
          value = "1024"
        },
        {
          name  = "AIRFLOW__CORE__MAX_ACTIVE_TASKS_PER_DAG"
          value = "4096"
        },
        {
          name  = "AIRFLOW__SCHEDULER__MAX_DAGRUNS_TO_CREATE_PER_LOOP"
          value = "256"
        },
        {
          name  = "AIRFLOW__SCHEDULER__SCHEDULER_HEARTBEAT_SEC"
          value = "1"
        },
        {
          name  = "AIRFLOW__KUBERNETES__WORKER_PODS_CREATION_BATCH_SIZE"
          value = "16"
        },
        {
          name  = "AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL"
          value = "10"
        },
        {
          name  = "AIRFLOW__SCHEDULER__MIN_FILE_PROCESS_INTERVAL"
          value = "5"
        },
        {
          name  = "AIRFLOW__CORE__DEFAULT_POOL_TASK_SLOT_COUNT"
          value = "1024"
        },
        {
          name  = "AIRFLOW__WEBSERVER__EXPOSE_CONFIG"
          value = "True"
        },
        {
          name  = "AWS_REGION"
          value = data.aws_region.current.name
        },
        {
          name  = "AWS_DEFAULT_REGION"
          value = data.aws_region.current.name
        }
      ]
    })
  ]

  depends_on = [var.cluster_endpoint, helm_release.keda]
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
