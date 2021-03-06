resource "aws_iam_role" "iam_for_shutdown_lambda" {
  name = "iam_for_shutdown_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "ec2" {
  statement {
    sid                      = "1"
    effect                   = "Allow"
    actions                  = [
      "ec2:*",
    ]
    resources                = [
      "*"
    ]
  }
}


resource "aws_iam_policy" "ec2_policy" {
  name   = "lambda_ec2_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ec2.json
}

resource "aws_iam_role_policy_attachment" "ec2_attach" {
  role       = aws_iam_role.iam_for_shutdown_lambda.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_lambda_function" "shutdown_lambda" {
  filename         = "shutdown_instances.zip"
  function_name    = "shutdown_instances"
  role             = aws_iam_role.iam_for_shutdown_lambda.arn
  handler          = "shutdown_instances.main"
  source_code_hash = filebase64sha256("shutdown_instances.zip")
  runtime          = "python3.8"
}

resource "aws_cloudwatch_event_rule" "shutdown_eventrule" {
  name                = "shutdown_instances"
  description         = "Shutdown instances"
  schedule_expression = "cron(0 18 * * ? *)" #run 6PM everyday
}

resource "aws_cloudwatch_event_target" "shutdown_target" {
  rule      = aws_cloudwatch_event_rule.shutdown_eventrule.name
  target_id = "shutdown_lambda"
  arn       = aws_lambda_function.shutdown_lambda.arn
}