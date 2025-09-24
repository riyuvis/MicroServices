output "bedrock_knowledge_base_id" {
  description = "ID of the Bedrock knowledge base"
  value       = aws_bedrockagent_knowledge_base.security_kb.id
}

output "bedrock_agent_id" {
  description = "ID of the Bedrock security agent"
  value       = aws_bedrockagent_agent.security_agent.id
}

output "bedrock_documents_bucket" {
  description = "S3 bucket for Bedrock documents"
  value       = aws_s3_bucket.bedrock_documents.bucket
}

output "opensearch_collection_arn" {
  description = "ARN of the OpenSearch Serverless collection"
  value       = aws_opensearchserverless_collection.bedrock_knowledge.arn
}

output "security_alerts_topic_arn" {
  description = "ARN of the SNS topic for security alerts"
  value       = aws_sns_topic.devsecops_security_alerts.arn
}

output "lambda_function_name" {
  description = "Name of the security analysis Lambda function"
  value       = aws_lambda_function.security_analysis.function_name
}

output "bedrock_execution_role_arn" {
  description = "ARN of the Bedrock execution role"
  value       = aws_iam_role.bedrock_execution_role.arn
}
