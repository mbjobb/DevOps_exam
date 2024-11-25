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
    source_code_hash = filebase64sha256("../provided_files/lambda_sqs.py")
    timeout = 30
    
    environment {
        variables = {
            BUCKET_NAME = var.output_bucket_name
        }
    }
}

resource "aws_lambda_function_url" "sqs_lambda_url" {
    function_name = aws_lambda_function.sqs_image_generator.function_name
    authorization_type = "NONE"
}
