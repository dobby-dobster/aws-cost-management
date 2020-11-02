resource "aws_iam_role" "iam_for_deletesgs_lambda" {
  name = "iam_for_securitygroup_lambda"

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

data "aws_iam_policy_document" "deletesgs_iam" {
  statement {
    sid                      = "1"
    effect                   = "Allow"
    actions                  = ["*"]
    resources                = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "deletesgs_policy" {
  name   = "lambda_deletesgs_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.deletesgs_iam.json
}

resource "aws_iam_role_policy_attachment" "sg_attach" {
  role       = aws_iam_role.iam_for_deletesgs_lambda.name
  policy_arn = aws_iam_policy.deletesgs_policy.arn
}

resource "aws_lambda_function" "deletesgs_lambda" {
  filename         = "delete_orphaned_securitygroups.zip"
  function_name    = "delete_orphaned_securitygroups"
  role             = aws_iam_role.iam_for_deletesgs_lambda.arn
  handler          = "delete_orphaned_securitygroups.main"
  source_code_hash = filebase64sha256("delete_orphaned_securitygroups.zip")
  runtime          = "python3.8"
}

resource "aws_cloudwatch_event_rule" "deletesgs_eventrule" {
  name                = "delete_orphaned_securitygroups"
  description         = "Delete orphaned security groups"
  schedule_expression = "cron(0 18 * * ? *)" #run 6PM everyday
}

resource "aws_cloudwatch_event_target" "deletesgs_target" {
  rule      = aws_cloudwatch_event_rule.deletesgs_eventrule.name
  target_id = "delete_orphaned_securitygroups"
  arn       = aws_lambda_function.deletesgs_lambda.arn
}