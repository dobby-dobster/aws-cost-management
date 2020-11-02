
data "aws_iam_policy_document" "cw" {
  statement {
    sid                      = "1"
    effect                   = "Allow"
    actions                  = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"

    ]
    resources                = [
      "*"
    ]
  }
}

resource "aws_iam_role" "iam_for_cw_lambda" {
  name = "iam_for_cloudwatch_lambda"

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

resource "aws_iam_policy" "cw_policy" {
  name   = "lambda_cloudwatch_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.cw.json
}

resource "aws_iam_role_policy_attachment" "cw_attach" {
  role       = aws_iam_role.iam_for_shutdown_lambda.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

                