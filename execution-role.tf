##
## Used to create the role ecs_execution below
##  - needed for FARGATE to execute tasks
##
data "aws_iam_policy_document" "ecs_execution_principal" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

##
## Used to add to update the role 
##  - Needed for FARGATE to write logs and get image from ECR
##
data "aws_iam_policy_document" "ecs_execution" {
  statement {
    sid    = "ServiceDefaults"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role" "ecs_execution" {
  name               = "${var.app_name}-exec-basic"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_principal.json
  path                 = "/"
}
resource "aws_iam_role_policy" "ecs_execution" {
  name   = "${var.app_name}-exec-basic"
  role   = aws_iam_role.ecs_execution.id
  policy = data.aws_iam_policy_document.ecs_execution.json
}