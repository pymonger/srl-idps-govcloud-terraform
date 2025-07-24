# SQS Queue for Karpenter Interruptions
resource "aws_sqs_queue" "karpenter_interruptions" {
  name = "${var.cluster_name}-karpenter"

  # Message retention period (4 days)
  message_retention_seconds = 345600

  # Visibility timeout (5 minutes)
  visibility_timeout_seconds = 300

  # Receive message wait time (20 seconds for long polling)
  receive_wait_time_seconds = 20

  # Dead letter queue configuration
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.karpenter_interruptions_dlq.arn
    maxReceiveCount     = 3
  })

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-karpenter-interruptions"
  })
}

# Dead Letter Queue for Karpenter
resource "aws_sqs_queue" "karpenter_interruptions_dlq" {
  name = "${var.cluster_name}-karpenter-dlq"

  message_retention_seconds = 1209600 # 14 days

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-karpenter-interruptions-dlq"
  })
}

# SQS Queue Policy for Karpenter
resource "aws_sqs_queue_policy" "karpenter_interruptions" {
  queue_url = aws_sqs_queue.karpenter_interruptions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = [
          "sqs:SendMessage"
        ]
        Resource = aws_sqs_queue.karpenter_interruptions.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = "arn:aws-us-gov:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/*"
          }
        }
      }
    ]
  })
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
