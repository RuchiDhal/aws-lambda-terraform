provider "aws" {
  region = "eu-west-1"  
}

resource "aws_iam_role" "aws_lambda_role" {
    name = "terraform_aws_lambda-role"
    assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
    name     = "aws_iam_policy_for_terraform_aws_lambda_role"
    path     = "/"
    policy   = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": [
            "logs:CreateLogsGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*",
        "Effect": "Allow"
        } 
    ]
}
EOF
}
  
resource "aws_iam_role_policy_attachment" "attach_iam_policy_iam_role" {
  role = aws_iam_role.aws_lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

data "archive_file" "python_code_zip" {
    type  = "zip"
    source_dir= "${path.module}/python/"
    output_path= "${path.module}/python/index.py.zip"

}

resource "aws_lambda_function" "terraform_lambda_function" {
    filename      = "${path.module}/python/index.py.zip"
    function_name = "lambda_function_name_1"
    role          = aws_iam_role.aws_lambda_role.arn
    handler       = "index.lambda_handler"
    runtime       = "python3.8"
    depends_on    = [ aws_iam_role_policy_attachment.attach_iam_policy_iam_role ]
}
 
output "terraform_aws_role_output" {
  value = aws_iam_role.aws_lambda_role.name
}
output "terraform_aws_role_arn_output" {
    value = aws_iam_role.aws_lambda_role.arn
  
}
output "terraform_logging_arn_output" {
    value = aws_iam_policy.iam_policy_for_lambda.arn
}