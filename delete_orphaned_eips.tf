resource "aws_iam_role" "iam_for_deleteeips_lambda" {
  name = "iam_for_eips_lambda"

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

data "aws_iam_policy_document" "deleteeips_iam" {
  statement {
    sid                      = "1"
    effect                   = "Allow"
    actions                  = [ "*"
    ]
    resources                = [
      "*"
    ]
  }
}


resource "aws_iam_policy" "deleteeips_policy" {
  name   = "lambda_delete_eipss_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.deleteeips_iam.json
}

resource "aws_iam_role_policy_attachment" "eip_attach" {
  role       = aws_iam_role.iam_for_deleteeips_lambda.name
  policy_arn = aws_iam_policy.deleteeips_policy.arn
}

resource "aws_lambda_function" "deleteeips_lambda" {
  filename         = "delete_orphaned_eips.zip"
  function_name    = "delete_orphaned_eips"
  role             = aws_iam_role.iam_for_deleteeips_lambda.arn
  handler          = "delete_orphaned_eips.main"
  source_code_hash = filebase64sha256("delete_orphaned_eips.zip")
  runtime          = "python3.8"
}

resource "aws_cloudwatch_event_rule" "deleteeips_eventrule" {
  name                = "delete_orphaned_eips"
  description         = "Delete orphaned eips"
  schedule_expression = "cron(0 18 * * ? *)" #run 6PM everyday
}

resource "aws_cloudwatch_event_target" "deleteeips_target" {
  rule      = aws_cloudwatch_event_rule.deleteeips_eventrule.name
  target_id = "delete_orphaned_eips"
  arn       = aws_lambda_function.deleteeips_lambda.arn
}