terraform {
  required_version = ">= 1.9"  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"  
    }
  }
  backend "s3" {
      bucket = "pgr301-2024-terraform-state"
      key = "14/sqs_lambda.tfstate"
      region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1" 
}


output "lambda_url" {
    value = aws_lambda_function_url.sqs_lambda_url.function_url
}