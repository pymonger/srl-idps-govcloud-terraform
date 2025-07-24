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

# Karpenter NodeClass - Defines AWS configuration for node provisioning
resource "kubernetes_manifest" "karpenter_nodeclass" {
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1beta1"
    kind       = "NodeClass"
    metadata = {
      name = "${var.cluster_name}-nodeclass"
    }
    spec = {
      amiFamily       = "AL2023"
      role            = "${var.cluster_name}-karpenter-node-role"
      instanceProfile = var.karpenter_node_instance_profile_name
      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      securityGroupSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      tags = {
        "karpenter.sh/discovery" = var.cluster_name
        "Environment"            = "production"
        "ManagedBy"              = "karpenter"
      }
      userData = base64encode(<<-EOF
        #!/bin/bash
        /etc/eks/bootstrap.sh ${var.cluster_name} --kubelet-extra-args '--node-labels=karpenter.sh/capacity-type={{CapacityType}} --node-labels=karpenter.k8s.aws/instance-category={{.Labels.karpenter.k8s.aws/instance-category}} --node-labels=karpenter.k8s.aws/instance-generation={{.Labels.karpenter.k8s.aws/instance-generation}} --node-labels=karpenter.k8s.aws/instance-size={{.Labels.karpenter.k8s.aws/instance-size}} --node-labels=karpenter.k8s.aws/instance-cpu={{.Labels.karpenter.k8s.aws/instance-cpu}} --node-labels=karpenter.k8s.aws/instance-memory={{.Labels.karpenter.k8s.aws/instance-memory}} --node-labels=karpenter.k8s.aws/instance-pods={{.Labels.karpenter.k8s.aws/instance-pods}} --node-labels=node.kubernetes.io/instance-type={{.Labels.node.kubernetes.io/instance-type}} --node-labels=topology.kubernetes.io/zone={{.Labels.topology.kubernetes.io/zone}} --node-labels=topology.kubernetes.io/region={{.Labels.topology.kubernetes.io/region}} --node-labels=karpenter.sh/provisioner-name={{.Labels.karpenter.sh/provisioner-name}} --node-labels=karpenter.sh/managed=true'
      EOF
      )
    }
  }

  depends_on = [helm_release.karpenter]
}

# Karpenter NodePool - Defines node requirements and constraints
resource "kubernetes_manifest" "karpenter_nodepool" {
  manifest = {
    apiVersion = "karpenter.sh/v1beta1"
    kind       = "NodePool"
    metadata = {
      name = "${var.cluster_name}-nodepool"
    }
    spec = {
      disruption = {
        consolidationPolicy = "WhenEmpty"
        consolidationTTL    = "30s"
      }
      nodeClassRef = {
        name = "${var.cluster_name}-nodeclass"
      }
      template = {
        metadata = {
          labels = {
            "karpenter.sh/capacity-type" = "spot"
            "node.kubernetes.io/role"    = "worker"
          }
        }
        spec = {
          requirements = [
            {
              key    = "kubernetes.io/arch"
              values = ["amd64"]
            },
            {
              key    = "kubernetes.io/os"
              values = ["linux"]
            },
            {
              key    = "karpenter.sh/capacity-type"
              values = ["spot", "on-demand"]
            },
            {
              key    = "node.kubernetes.io/instance-type"
              values = ["c6i.large", "c6i.xlarge", "c6i.2xlarge"]
            },
            {
              key    = "topology.kubernetes.io/zone"
              values = ["us-gov-west-1a", "us-gov-west-1b", "us-gov-west-1c"]
            }
          ]
          startupTaints = [
            {
              key    = "karpenter.sh/initializing"
              value  = "true"
              effect = "NoSchedule"
            }
          ]
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.karpenter_nodeclass]
}

# Data source to read existing aws-auth ConfigMap
data "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}

# AWS Auth ConfigMap - Update existing aws-auth to include Karpenter node role
resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(concat(
      # Parse existing mapRoles from the data source
      yamldecode(data.kubernetes_config_map_v1.aws_auth.data.mapRoles),
      # Add Karpenter node role entry
      [
        {
          rolearn  = var.karpenter_node_role_arn
          username = "system:node:{{EC2PrivateDNSName}}"
          groups = [
            "system:bootstrappers",
            "system:nodes"
          ]
        }
      ]
    ))
  }

  depends_on = [data.kubernetes_config_map_v1.aws_auth, kubernetes_manifest.karpenter_nodepool]
}

# Airflow Helm Release
resource "helm_release" "airflow" {
  name             = "airflow"
  repository       = "https://airflow.apache.org/charts"
  chart            = "airflow"
  namespace        = "sps"
  create_namespace = true
  version          = "1.12.0"

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
        extraVolumes = concat([
          {
            name = "workers-volume"
            persistentVolumeClaim = {
              claimName = "airflow-kpo"
            }
          }
          ], var.deploy_dags ? [
          {
            name = "dag-configmaps"
            configMap = {
              name = "airflow-dag-configmaps"
            }
          }
        ] : [])
        extraVolumeMounts = concat([
          {
            name      = "workers-volume"
            mountPath = "/shared-task-data"
            readOnly  = false
          }
          ], var.deploy_dags ? [
          {
            name      = "dag-configmaps"
            mountPath = "/opt/airflow/dags"
            readOnly  = true
          }
        ] : [])
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
        extraVolumeMounts = var.deploy_dags ? [
          {
            name      = "dag-configmaps"
            mountPath = "/opt/airflow/dags"
            readOnly  = true
          }
        ] : []
        extraVolumes = var.deploy_dags ? [
          {
            name = "dag-configmaps"
            configMap = {
              name = "airflow-dag-configmaps"
            }
          }
        ] : []
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
        extraVolumeMounts = var.deploy_dags ? [
          {
            name      = "dag-configmaps"
            mountPath = "/opt/airflow/dags"
            readOnly  = true
          }
        ] : []
        extraVolumes = var.deploy_dags ? [
          {
            name = "dag-configmaps"
            configMap = {
              name = "airflow-dag-configmaps"
            }
          }
        ] : []
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
        extraVolumeMounts = var.deploy_dags ? [
          {
            name      = "dag-configmaps"
            mountPath = "/opt/airflow/dags"
            readOnly  = true
          }
        ] : []
        extraVolumes = var.deploy_dags ? [
          {
            name = "dag-configmaps"
            configMap = {
              name = "airflow-dag-configmaps"
            }
          }
        ] : []
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

  depends_on = [helm_release.karpenter]
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Combined DAG ConfigMap for Airflow
resource "kubernetes_config_map_v1" "airflow_dags" {
  count = var.deploy_dags ? 1 : 0

  metadata {
    name      = "airflow-dag-configmaps"
    namespace = "sps"
    labels = {
      "app.kubernetes.io/name"      = "airflow"
      "app.kubernetes.io/instance"  = "airflow"
      "app.kubernetes.io/component" = "dag"
    }
  }

  data = {
    "rdrgen.py"  = file("${path.module}/dags/rdrgen.py")
    "edrgen.py"  = file("${path.module}/dags/edrgen.py")
    "vic2png.py" = file("${path.module}/dags/vic2png.py")
  }

  depends_on = [helm_release.airflow]
}
