# DevSecOps AWS Infrastructure with Bedrock Integration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }

  backend "s3" {
    bucket = "devsecops-terraform-state"
    key    = "infrastructure/terraform.tfstate"
    region = "us-east-1"
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "DevSecOps-Microservices"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "DevSecOps-Team"
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Local values
locals {
  name = "${var.project_name}-${var.environment}"
  
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name        = local.name
    Environment = var.environment
  }
}

# VPC Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-vpc"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = true
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Security Groups
  manage_default_security_group = true
  default_security_group_name   = "${local.name}-default"
  default_security_group_egress = []
  default_security_group_ingress = []

  tags = local.tags
}

# EKS Cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "${local.name}-eks"
  cluster_version = var.kubernetes_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    main = {
      name = "${local.name}-node-group"

      instance_types = var.node_instance_types
      capacity_type  = "ON_DEMAND"

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      disk_size = 50
      disk_type = "gp3"

      labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }

      tags = local.tags
    }
  }

  # AWS Load Balancer Controller
  enable_aws_load_balancer_controller = true

  tags = local.tags
}

# AWS Bedrock Foundation Model Access
resource "aws_bedrock_model_invocation_logging_configuration" "main" {
  logging_config {
    embedding_data_delivery_enabled = true
    image_data_delivery_enabled     = true
    text_data_delivery_enabled      = true
    
    s3_config {
      bucket_name = aws_s3_bucket.bedrock_logs.bucket
      key_prefix  = "bedrock-logs/"
    }
  }
}

# S3 Bucket for Bedrock logs
resource "aws_s3_bucket" "bedrock_logs" {
  bucket = "${local.name}-bedrock-logs"

  tags = local.tags
}

resource "aws_s3_bucket_versioning" "bedrock_logs" {
  bucket = aws_s3_bucket.bedrock_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bedrock_logs" {
  bucket = aws_s3_bucket.bedrock_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# AWS Secrets Manager for application secrets
resource "aws_secretsmanager_secret" "app_secrets" {
  name        = "${local.name}-app-secrets"
  description = "Application secrets for microservices"

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    database_url = "postgresql://user:password@rds-endpoint:5432/db"
    jwt_secret   = "your-jwt-secret-here"
    api_keys     = {
      external_service = "your-api-key-here"
    }
  })
}

# AWS Config for compliance monitoring
resource "aws_config_configuration_recorder" "main" {
  name     = "${local.name}-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  depends_on = [aws_config_delivery_channel.main]
}

resource "aws_config_delivery_channel" "main" {
  name           = "${local.name}-config-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
}

resource "aws_s3_bucket" "config_bucket" {
  bucket = "${local.name}-config-bucket"

  tags = local.tags
}

resource "aws_iam_role" "config_role" {
  name = "${local.name}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config_role" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/ConfigRole"
}

# AWS Security Hub
resource "aws_securityhub_account" "main" {
  enable_default_standards = true
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "microservices" {
  name              = "/aws/eks/${local.name}-eks/cluster"
  retention_in_days = 30

  tags = local.tags
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = local.tags
}

resource "aws_security_group" "alb" {
  name_prefix = "${local.name}-alb-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name}-alb-sg"
  })
}

# RDS Database
module "rds" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "${local.name}-db"

  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = var.db_instance_class
  allocated_storage = 20

  db_name  = "microservices"
  username = "postgres"
  password = "changeme123" # Should use AWS Secrets Manager in production
  port     = "5432"

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  deletion_protection = false

  tags = local.tags
}

resource "aws_db_subnet_group" "main" {
  name       = "${local.name}-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = local.tags
}

resource "aws_security_group" "rds" {
  name_prefix = "${local.name}-rds-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name}-rds-sg"
  })
}

resource "aws_security_group" "eks_nodes" {
  name_prefix = "${local.name}-eks-nodes-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Node to node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name}-eks-nodes-sg"
  })
}
