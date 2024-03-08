
##
## Create CloudWatch group and log stream
##  - retention is set to 1 day
##
 resource "aws_cloudwatch_log_group" "app_log_group" {
   name              = "ecs/${var.app_name}"
   retention_in_days = 1
 }
 
##
## Create the ECS Cluster and set capacity provider to FARGATE_SPOT
##  - FARGATE_SPOT is a cost saver!
##
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.9.1"

  cluster_name = var.app_name
  cluster_settings = [
    {"name": "containerInsights", "value": "disabled" }
  ]
  # * Using FARGATE_SPOT to reduce cost for testing
  fargate_capacity_providers = {
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }
}

##
## Create the Task Definition for the services
##
resource "aws_ecs_task_definition" "app" {
    family                   = "${var.app_name}-task"
    execution_role_arn       = aws_iam_role.ecs_execution.arn
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.fargate_cpu
    memory                   = var.fargate_memory
    container_definitions    = jsonencode(
    [
      {
        "cpu": "${var.fargate_cpu}",
        "memory": "${var.fargate_memory}",
        "networkMode": "awsvpc",
        "image": "${local.aws_ecr_uri}:${var.image_tag}",
        "name": "${var.app_name}",
        "portMappings": [
          {
            "containerPort": "${var.app_port}"
          }
        ],
        "logConfiguration": {
           "logDriver": "awslogs",
           "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.app_log_group.id}",
              "awslogs-region": "${var.aws_region}",
              "awslogs-stream-prefix": "ecs"
           }
        }
      }
    ]
  )
  depends_on = [aws_iam_role.ecs_execution, aws_cloudwatch_log_group.app_log_group]
}

## 
## Create the service using FARGATE
##  - add to the ALB created
##
resource "aws_ecs_service" "main" {
    name            = var.app_name
    cluster         = module.ecs.cluster_arn
    task_definition = aws_ecs_task_definition.app.arn
    desired_count   = var.fargate_desired_count
    launch_type     = "FARGATE"

    network_configuration {
        security_groups  = [aws_security_group.ecs_tasks.id]
        subnets          = module.vpc.private_subnets
        assign_public_ip = false
    }
    load_balancer {
        target_group_arn = aws_alb_target_group.app.id
        container_name   = var.app_name
        container_port   = var.app_port
    }

    depends_on = [aws_alb_listener.front_end, module.vpc_endpoints]
}

