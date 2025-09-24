# AWS Bedrock Infrastructure for DevSecOps
# Creates Bedrock flows, agents, knowledge bases, and supporting resources

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local variables
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  
  common_tags = {
    Environment = var.environment
    Project     = "DevSecOps"
    Team        = "Security"
    ManagedBy   = "Terraform"
  }
}

# S3 bucket for Bedrock knowledge base documents
resource "aws_s3_bucket" "bedrock_documents" {
  bucket = "${var.project_name}-${var.environment}-bedrock-documents"

  tags = merge(local.common_tags, {
    Name = "Bedrock Documents Storage"
    Type = "KnowledgeBase"
  })
}

resource "aws_s3_bucket_versioning" "bedrock_documents" {
  bucket = aws_s3_bucket.bedrock_documents.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bedrock_documents" {
  bucket = aws_s3_bucket.bedrock_documents.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# OpenSearch Serverless collection for vector storage
resource "aws_opensearchserverless_collection" "bedrock_knowledge" {
  name = "${var.project_name}-${var.environment}-bedrock-knowledge"
  type = "VECTORSEARCH"

  tags = merge(local.common_tags, {
    Name = "Bedrock Knowledge Vector Store"
  })
}

# OpenSearch Serverless encryption policy
resource "aws_opensearchserverless_security_policy" "bedrock_encryption" {
  name = "${var.project_name}-${var.environment}-bedrock-encryption"
  type = "encryption"

  policy = jsonencode({
    Rules = [
      {
        ResourceType = "collection"
        Resource = [
          "collection/${aws_opensearchserverless_collection.bedrock_knowledge.name}"
        ]
      }
    ]
    AWSOwnedKey = true
  })
}

# OpenSearch Serverless network policy
resource "aws_opensearchserverless_security_policy" "bedrock_network" {
  name = "${var.project_name}-${var.environment}-bedrock-network"
  type = "network"

  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection"
          Resource = [
            "collection/${aws_opensearchserverless_collection.bedrock_knowledge.name}"
          ]
          AllowFromPublic = true
        }
      ]
      AllowFromPublic = true
    }
  ])
}

# OpenSearch Serverless data access policy
resource "aws_opensearchserverless_access_policy" "bedrock_data_access" {
  name = "${var.project_name}-${var.environment}-bedrock-data-access"
  type = "data"

  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection"
          Resource = [
            "collection/${aws_opensearchserverless_collection.bedrock_knowledge.name}"
          ]
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DeleteCollectionItems",
            "aoss:UpdateCollectionItems",
            "aoss:DescribeCollectionItems"
          ]
        },
        {
          ResourceType = "index"
          Resource = [
            "index/${var.project_name}-${var.environment}-bedrock-knowledge/*"
          ]
          Permission = [
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:UpdateIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:WriteDocument"
          ]
        }
      ]
      Principal = [
        "arn:aws:iam::${local.account_id}:role/${var.project_name}-${var.environment}-bedrock-execution-role"
      ]
    }
  ])
}

# IAM role for Bedrock execution
resource "aws_iam_role" "bedrock_execution_role" {
  name = "${var.project_name}-${var.environment}-bedrock-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "Bedrock Execution Role"
  })
}

# IAM role for Bedrock knowledge base
resource "aws_iam_role" "bedrock_knowledge_base_role" {
  name = "${var.project_name}-${var.environment}-bedrock-knowledge-base-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "Bedrock Knowledge Base Role"
  })
}

# IAM policy for Bedrock execution
resource "aws_iam_policy" "bedrock_execution_policy" {
  name        = "${var.project_name}-${var.environment}-bedrock-execution-policy"
  description = "Policy for Bedrock execution with DevSecOps permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:${local.region}::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0",
          "arn:aws:bedrock:${local.region}::foundation-model/amazon.titan-embed-text-v1"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.bedrock_documents.arn,
          "${aws_s3_bucket.bedrock_documents.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "aoss:APIAccessAll"
        ]
        Resource = aws_opensearchserverless_collection.bedrock_knowledge.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/bedrock/*"
      }
    ]
  })

  tags = local.common_tags
}

# IAM policy for Bedrock knowledge base
resource "aws_iam_policy" "bedrock_knowledge_base_policy" {
  name        = "${var.project_name}-${var.environment}-bedrock-knowledge-base-policy"
  description = "Policy for Bedrock knowledge base operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.bedrock_documents.arn,
          "${aws_s3_bucket.bedrock_documents.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "aoss:APIAccessAll"
        ]
        Resource = aws_opensearchserverless_collection.bedrock_knowledge.arn
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = [
          "arn:aws:bedrock:${local.region}::foundation-model/amazon.titan-embed-text-v1"
        ]
      }
    ]
  })

  tags = local.common_tags
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "bedrock_execution_policy_attachment" {
  role       = aws_iam_role.bedrock_execution_role.name
  policy_arn = aws_iam_policy.bedrock_execution_policy.arn
}

resource "aws_iam_role_policy_attachment" "bedrock_knowledge_base_policy_attachment" {
  role       = aws_iam_role.bedrock_knowledge_base_role.name
  policy_arn = aws_iam_policy.bedrock_knowledge_base_policy.arn
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "bedrock_execution_bedrock_policy" {
  role       = aws_iam_role.bedrock_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

resource "aws_iam_role_policy_attachment" "bedrock_knowledge_base_bedrock_policy" {
  role       = aws_iam_role.bedrock_knowledge_base_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

# SNS topic for security alerts
resource "aws_sns_topic" "devsecops_security_alerts" {
  name = "${var.project_name}-${var.environment}-security-alerts"

  tags = merge(local.common_tags, {
    Name = "DevSecOps Security Alerts"
  })
}

# SNS topic subscription (email)
resource "aws_sns_topic_subscription" "security_alerts_email" {
  count     = var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.devsecops_security_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Lambda function for security analysis action
resource "aws_lambda_function" "security_analysis" {
  filename         = "security-analysis-lambda.zip"
  function_name    = "${var.project_name}-${var.environment}-security-analysis"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 300

  environment {
    variables = {
      KNOWLEDGE_BASE_ID = aws_bedrockagent_knowledge_base.security_kb.id
      SNS_TOPIC_ARN     = aws_sns_topic.devsecops_security_alerts.arn
    }
  }

  tags = merge(local.common_tags, {
    Name = "Security Analysis Lambda"
  })
}

# Lambda execution role
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}-${var.environment}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Lambda execution policy
resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "${var.project_name}-${var.environment}-lambda-execution-policy"
  description = "Policy for Lambda execution with Bedrock access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${local.region}:${local.account_id}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrockagent:Retrieve",
          "bedrockagent:RetrieveAndGenerate"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.devsecops_security_alerts.arn
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Bedrock Knowledge Base
resource "aws_bedrockagent_knowledge_base" "security_kb" {
  name     = "${var.project_name}-${var.environment}-security-kb"
  role_arn = aws_iam_role.bedrock_knowledge_base_role.arn

  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${local.region}::foundation-model/amazon.titan-embed-text-v1"
    }
    type = "VECTOR"
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.bedrock_knowledge.arn
      vector_index_name = "${var.project_name}-${var.environment}-vector-index"
      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }

  tags = merge(local.common_tags, {
    Name = "Security Knowledge Base"
  })
}

# Bedrock Knowledge Base Data Source
resource "aws_bedrockagent_data_source" "security_docs" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.security_kb.id
  name              = "security-documents"
  description       = "Security documentation and guidelines"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.bedrock_documents.arn
      inclusion_prefixes = ["security-docs/"]
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "FIXED_SIZE"
      fixed_size_chunking_configuration {
        max_tokens         = 512
        overlap_percentage = 20
      }
    }
  }
}

# Bedrock Agent
resource "aws_bedrockagent_agent" "security_agent" {
  agent_name              = "${var.project_name}-${var.environment}-security-agent"
  agent_resource_role_arn = aws_iam_role.bedrock_execution_role.arn
  description             = "AI-powered security analysis agent for DevSecOps"

  instruction = <<-EOT
    You are a specialized security analysis agent for DevSecOps pipelines. Your role is to:
    
    1. Security Analysis: Analyze code repositories for security vulnerabilities including:
       - Injection vulnerabilities (SQL, NoSQL, LDAP, OS command)
       - Cross-Site Scripting (XSS) vulnerabilities
       - Authentication and session management flaws
       - Authorization bypasses and privilege escalation
       - Cryptographic weaknesses
       - Input validation issues
       - Security misconfigurations
       - Sensitive data exposure
       - Insecure deserialization
       - Known vulnerable components
    
    2. Compliance Assessment: Evaluate code against compliance frameworks:
       - SOC 2 Type II controls
       - PCI DSS requirements
       - HIPAA security rules
       - GDPR data protection
       - ISO 27001 standards
    
    3. Risk Assessment: Provide detailed risk analysis including:
       - CVSS scoring for vulnerabilities
       - Business impact assessment
       - Exploitability analysis
       - Remediation priority ranking
    
    4. Remediation Guidance: Generate actionable fixes:
       - Specific code changes
       - Configuration updates
       - Security best practices
       - Implementation timelines
    
    Always provide clear, actionable recommendations with code examples and prioritize critical vulnerabilities that could lead to data breaches or system compromise.
  EOT

  foundation_model = "anthropic.claude-3-5-sonnet-20241022-v2"

  tags = merge(local.common_tags, {
    Name = "Security Analysis Agent"
  })
}

# Bedrock Agent Action Group
resource "aws_bedrockagent_agent_action_group" "security_analysis" {
  action_group_name = "SecurityAnalysis"
  agent_id          = aws_bedrockagent_agent.security_agent.id
  agent_version     = "DRAFT"
  description       = "Perform comprehensive security analysis"

  action_group_executor {
    lambda = aws_lambda_function.security_analysis.arn
  }

  api_schema {
    payload = jsonencode({
      type = "object"
      properties = {
        repositoryUrl = {
          type        = "string"
          description = "Git repository URL to analyze"
        }
        scanType = {
          type        = "string"
          enum        = ["full", "incremental", "dependency"]
          description = "Type of security scan"
        }
      }
      required = ["repositoryUrl"]
    })
  }
}

# Bedrock Agent Knowledge Base Association
resource "aws_bedrockagent_agent_knowledge_base" "security_kb_association" {
  agent_id          = aws_bedrockagent_agent.security_agent.id
  agent_version     = "DRAFT"
  knowledge_base_id = aws_bedrockagent_knowledge_base.security_kb.id
  description       = "Security knowledge base for the agent"
}
