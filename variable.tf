variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

provider "aws" {
  region = var.region
}

##This is EKS cluster name 
locals {
  cluster_name = "test-eks"
}