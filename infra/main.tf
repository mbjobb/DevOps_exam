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

data "archive_file" "lambda_zip" {
    type = "zip"
    source_file = "../provided_files/lambda_sqs.py"
    output_path = "../lambda_sqs.zip"
}

resource "aws_lambda_function" "sqs_image_generator" {
    function_name = "${var.candidate_prefix}_sqs_image_generator"
    runtime = "python3.8"
    handler = "lambda_sqs.lambda_handler"
    role = aws_iam_role.sqs_lambda_role.arn
    filename = "../lambda_sqs.zip"
    timeout = 30
    
    environment {
        variables = {
            BUCKET_NAME = var.output_bucket_name
        }
    }
}

resource "aws_iam_role" "sqs_lambda_role" {
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Effect": "Allow",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                }
            }
        ]
    })
    
    name = "${var.candidate_prefix}_sqs_lambda_role"
}


resource "aws_iam_role_policy" "sqs_bedrock_policy" {
    name = "${var.candidate_prefix}_SQS_BedrockPolicy"
    role = aws_iam_role.sqs_lambda_role.id
    
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                    "bedrock:InvokeModel"
                ],
                "Resource": "*",
                "Effect": "Allow"
            }
        ]
    })
}


resource "aws_iam_role_policy" "sqs_s3_policy" {
    name = "${var.candidate_prefix}_SQS_S3Policy"
    role = aws_iam_role.sqs_lambda_role.id
    
    policy = jsonencode ({
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                  "s3:PutObject",
                  "s3:PutObjectAcl",
                  "s3:PutLifecycleConfiguration"
                ],
                "Resource": "arn:aws:s3:::${var.output_bucket_name}"
                
            }
        ]
       
    })
}

resource "aws_iam_role_policy" "lambda_que_policy" {
    name = "${var.candidate_prefix}_lambda_que_policy"
    role = aws_iam_role.sqs_lambda_role.id
    
    policy = jsonencode ({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                    "sqs:*"
                ],
                "Effect": "Allow",
                "Resource": "*"
            }
        ]   
    })
}

resource "aws_lambda_function_url" "sqs_lambda_url" {
    function_name = aws_lambda_function.sqs_image_generator.function_name
    authorization_type = "NONE"
}

resource "aws_lambda_permission" "allow_lambda_url" {
    statement_id = "AllowLambdaUrlInvoke"
    action = "lambda:InvokeFunctionUrl"
    function_name = aws_lambda_function.sqs_image_generator.function_name
    principal = "*"
    function_url_auth_type = aws_lambda_function_url.sqs_lambda_url.authorization_type
}

output "lambda_url" {
    value = aws_lambda_function_url.sqs_lambda_url.function_url
}
resource "aws_sqs_queue" "lambda_que" {
    name = "${var.candidate_prefix}_Lambda_SQS"
}
resource "aws_lambda_event_source_mapping" "lambda_event_que" {
    batch_size = 1
    event_source_arn = "${aws_sqs_queue.lambda_que.arn}"
    enabled = true
    function_name = aws_lambda_function.sqs_image_generator.function_name
}