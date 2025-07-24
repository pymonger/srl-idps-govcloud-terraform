# ECR Repository for custom Airflow image
resource "aws_ecr_repository" "airflow" {
  name                 = "airflow"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-airflow-ecr"
  })
}

# ECR Repository for Karpenter images
resource "aws_ecr_repository" "karpenter_controller" {
  name                 = "karpenter/controller"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-karpenter-controller-ecr"
  })
}

resource "aws_ecr_repository" "karpenter_webhook" {
  name                 = "karpenter/webhook"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-karpenter-webhook-ecr"
  })
}

# ECR Repository for KEDA images
resource "aws_ecr_repository" "keda_operator" {
  name                 = "kedacore/keda"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-keda-operator-ecr"
  })
}

resource "aws_ecr_repository" "keda_metrics_apiserver" {
  name                 = "kedacore/keda-metrics-apiserver"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-keda-metrics-apiserver-ecr"
  })
}

resource "aws_ecr_repository" "keda_admission_webhooks" {
  name                 = "kedacore/keda-admission-webhooks"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-keda-admission-webhooks-ecr"
  })
}

# ECR Repository for supporting images
resource "aws_ecr_repository" "statsd_exporter" {
  name                 = "statsd-exporter"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-statsd-exporter-ecr"
  })
}

resource "aws_ecr_repository" "redis" {
  name                 = "redis"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-redis-ecr"
  })
}

resource "aws_ecr_repository" "git_sync" {
  name                 = "git-sync/git-sync"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-git-sync-ecr"
  })
}

resource "aws_ecr_repository" "postgresql" {
  name                 = "postgresql"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-postgresql-ecr"
  })
}

# ECR Repository for Alpine base image (for sidecars and init containers)
resource "aws_ecr_repository" "alpine" {
  name                 = "unity/alpine"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-alpine-ecr"
  })
}

# ECR Repository for Busybox base image (for sidecars and init containers)
resource "aws_ecr_repository" "busybox" {
  name                 = "unity/busybox"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-busybox-ecr"
  })
}

# ECR Repository for Nginx base image (for sidecars and init containers)
resource "aws_ecr_repository" "nginx" {
  name                 = "unity/nginx"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-nginx-ecr"
  })
}

# ECR Repository for Unity RDRGEN image
resource "aws_ecr_repository" "rdrgen" {
  name                 = "unity/rdrgen"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-rdrgen-ecr"
  })
}

# ECR Repository for Unity EDRGEN image
resource "aws_ecr_repository" "edrgen" {
  name                 = "unity/edrgen"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-edrgen-ecr"
  })
}

# ECR Repository for Unity VIC2PNG image
resource "aws_ecr_repository" "vic2png" {
  name                 = "unity/vic2png"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-vic2png-ecr"
  })
}

# ECR Repository for EKS pause image (required for Karpenter nodes)
resource "aws_ecr_repository" "eks_pause" {
  name                 = "eks/pause"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-eks-pause-ecr"
  })
}

# ECR Lifecycle Policy for cleanup
resource "aws_ecr_lifecycle_policy" "airflow" {
  repository = aws_ecr_repository.airflow.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
