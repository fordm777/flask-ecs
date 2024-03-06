##
## Create the VPC
##
data "aws_availability_zones" "available" { state = "available" }
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5.2"

  name                = var.app_name
  # Span subnetworks across 2 avalibility zones
  azs                 = slice(data.aws_availability_zones.available.names, 0, 2) 
  cidr                = var.aws_cdir
  create_vpc          = true
  create_igw          = true # Expose public subnetworks to the Internet
  private_subnets     = var.aws_private_subnets
  public_subnets      = var.aws_public_subnets
  #enable_nat_gateway = var.aws_enable_nat # Hide private subnetworks behind NAT Gateway
  #single_nat_gateway = true
}

##
## Create the ALB security group
##
resource "aws_security_group" "alb" {
    name        = "${var.app_name}-alb-sg"
    description = "controls access to the ALB"
    vpc_id      = module.vpc.vpc_id

    ingress {
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

##
## Create the ECS task security group
##  - restrict access to only ALB security group 
##
resource "aws_security_group" "ecs_tasks" {
    name        = "${var.app_name}-ecs-tasks-sg"
    description = "allow inbound access from the ALB only"
    vpc_id      = module.vpc.vpc_id

    ingress {
        protocol        = "tcp"
        from_port       = var.app_port
        to_port         = var.app_port
        security_groups = [aws_security_group.alb.id]
    }
    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
    depends_on = [aws_security_group.alb]
}

##
##  Create the ALB to access from internet
##
resource "aws_alb" "main" {
    name            = "${var.app_name}-public-alb"
    subnets         = module.vpc.public_subnets
    security_groups = [aws_security_group.alb.id]
}

##
## Create the Target group to point to the application port
## 
resource "aws_alb_target_group" "app" {
    name        = "${var.app_name}"
    port        = var.app_port
    protocol    = "HTTP"
    vpc_id      = module.vpc.vpc_id
    target_type = "ip"

    health_check {
        healthy_threshold   = "3"
        interval            = "30"
        protocol            = "HTTP"
        matcher             = "200"
        timeout             = "3"
        path                = "/"
        unhealthy_threshold = "2"
    }
}

##
## Create listener to Redirect all traffic from the ALB to the target group
##
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}

##
## Output the ALB URL
##
output "URL" {
  description = "The URL to access test app"
  value = "http://${aws_alb.main.dns_name}/"
}