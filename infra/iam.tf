
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
                "Resource": "arn:aws:s3:::${var.output_bucket_name}/*" 
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
            },
            {
                Effect   = "Allow"
                Action   = "sns:Publish"
                Resource = aws_sns_topic.message_age.arn
            }
        ]   
    })
}

resource "aws_lambda_permission" "allow_lambda_url" {
    statement_id = "AllowLambdaUrlInvoke"
    action = "lambda:InvokeFunctionUrl"
    function_name = aws_lambda_function.sqs_image_generator.function_name
    principal = "*"
    function_url_auth_type = aws_lambda_function_url.sqs_lambda_url.authorization_type
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.sqs_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
