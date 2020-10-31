resource "aws_iam_role" "iam_for_deletevolumes_lambda" {
  name = "iam_for_volume_lambda"

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

data "aws_iam_policy_document" "deletevolumes_iam" {
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


resource "aws_iam_policy" "deletevolume_policy" {
  name   = "lambda_deletevolume_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.deletevolumes_iam.json
}

resource "aws_iam_role_policy_attachment" "volume_attach" {
  role       = aws_iam_role.iam_for_deletevolumes_lambda.name
  policy_arn = aws_iam_policy.deletevolume_policy.arn
}

resource "aws_lambda_function" "deletevolumes_lambda" {
  filename         = "delete_orphaned_volumes.zip"
  function_name    = "delete_orphaned_volumes"
  role             = aws_iam_role.iam_for_deletevolumes_lambda.arn
  handler          = "delete_orphaned_volumes.main"
  source_code_hash = filebase64sha256("delete_orphaned_volumes.zip")
  runtime          = "python3.8"
}

resource "aws_cloudwatch_event_rule" "deletevolumes_eventrule" {
  name                = "delete_orphaned_volumes"
  description         = "Delete orphaned volumes"
  schedule_expression = "cron(0 18 * * ? *)" #run 6PM everyday
}

resource "aws_cloudwatch_event_target" "deletevolumes_target" {
  rule      = aws_cloudwatch_event_rule.deletevolumes_eventrule.name
  target_id = "delete_orphaned_volumes"
  arn       = aws_lambda_function.deletevolumes_lambda.arn
}