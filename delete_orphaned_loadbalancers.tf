resource "aws_iam_role" "iam_for_deletelbs_lambda" {
  name = "iam_for_loadbalancer_lambda"

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

data "aws_iam_policy_document" "deletelbs_iam" {
  statement {
    sid                      = "1"
    effect                   = "Allow"
    actions                  = [
      "elasticloadbalancing:*", "ec2:*",
    ]
    resources                = [
      "*"
    ]
  }
}



resource "aws_iam_policy" "deletelb_policy" {
  name   = "lambda_deletelb_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.deletelbs_iam.json
}

resource "aws_iam_role_policy_attachment" "lb_attach" {
  role       = aws_iam_role.iam_for_deletelbs_lambda.name
  policy_arn = aws_iam_policy.deletelb_policy.arn
}

resource "aws_lambda_function" "deletelbs_lambda" {
  filename         = "delete_orphaned_loadbalancers.zip"
  function_name    = "delete_orphaned_loadbalancers"
  role             = aws_iam_role.iam_for_deletelbs_lambda.arn
  handler          = "delete_orphaned_loadbalancers.main"
  source_code_hash = filebase64sha256("delete_orphaned_loadbalancers.zip")
  runtime          = "python3.8"
}

resource "aws_cloudwatch_event_rule" "deletelbs_eventrule" {
  name                = "delete_orphaned_loadbalancers"
  description         = "Delete orphaned loadbalancers"
  schedule_expression = "cron(0 18 * * ? *)" #run 6PM everyday
}

resource "aws_cloudwatch_event_target" "deletelbs_target" {
  rule      = aws_cloudwatch_event_rule.deletelbs_eventrule.name
  target_id = "delete_orphaned_loadbalancers"
  arn       = aws_lambda_function.deletelbs_lambda.arn
}