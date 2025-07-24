output "karpenter_queue_url" {
  description = "Karpenter interruption queue URL"
  value       = aws_sqs_queue.karpenter_interruptions.url
}

output "karpenter_queue_arn" {
  description = "Karpenter interruption queue ARN"
  value       = aws_sqs_queue.karpenter_interruptions.arn
}

output "karpenter_dlq_url" {
  description = "Karpenter dead letter queue URL"
  value       = aws_sqs_queue.karpenter_interruptions_dlq.url
}

output "karpenter_dlq_arn" {
  description = "Karpenter dead letter queue ARN"
  value       = aws_sqs_queue.karpenter_interruptions_dlq.arn
}
