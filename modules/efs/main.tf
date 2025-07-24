# EFS File System
resource "aws_efs_file_system" "airflow" {
  creation_token = "${var.cluster_name}-airflow-efs"
  encrypted      = true

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-airflow-efs"
  })
}

# EFS Mount Targets
resource "aws_efs_mount_target" "airflow" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.airflow.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

# EFS Security Group
resource "aws_security_group" "efs" {
  name_prefix = "${var.cluster_name}-efs-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from EKS nodes"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-efs-sg"
  })
}

# EFS Access Points
resource "aws_efs_access_point" "airflow_dags" {
  file_system_id = aws_efs_file_system.airflow.id

  root_directory {
    path = "/airflow-dags"
    creation_info {
      owner_gid   = 50000
      owner_uid   = 50000
      permissions = "755"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-airflow-dags-ap"
  })
}

resource "aws_efs_access_point" "airflow_logs" {
  file_system_id = aws_efs_file_system.airflow.id

  root_directory {
    path = "/airflow-logs"
    creation_info {
      owner_gid   = 50000
      owner_uid   = 50000
      permissions = "755"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-airflow-logs-ap"
  })
}

resource "aws_efs_access_point" "shared_task_data" {
  file_system_id = aws_efs_file_system.airflow.id

  root_directory {
    path = "/shared-task-data"
    creation_info {
      owner_gid   = 50000
      owner_uid   = 50000
      permissions = "755"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-shared-task-data-ap"
  })
}
