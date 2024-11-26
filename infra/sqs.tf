resource "aws_sqs_queue" "lambda_que" {
    name = "${var.candidate_prefix}_Lambda_SQS"
}

resource "aws_lambda_event_source_mapping" "lambda_event_que" {
    batch_size = 1
    event_source_arn = "${aws_sqs_queue.lambda_que.arn}"
    enabled = true
    function_name = aws_lambda_function.sqs_image_generator.function_name
}

