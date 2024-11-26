resource "aws_cloudwatch_metric_alarm" "message_age_alarm" {
    alarm_name           = "${var.candidate_prefix}-Message-age-alarm"
    statistic           = "Average"
    metric_name         = "ApproximateAgeOfOldestMessage"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    datapoints_to_alarm = 1
    threshold           = 15  
    period              = 60  
    evaluation_periods  = 1
    namespace           = "AWS/SQS"
    
    dimensions = {
        QueName = aws_sqs_queue.lambda_que.name
    }
    
    alarm_description = "Alarm that goes off when the average age of the oldest message exceeds 30 seconds."
    alarm_actions = [aws_sns_topic.message_age.arn]
    treat_missing_data = "notBreaching"
}




resource "aws_sns_topic_subscription" "message_age_sqs_target" {
    topic_arn = aws_sns_topic.message_age.arn
    protocol = "email"
    endpoint = var.alarm_email
}

