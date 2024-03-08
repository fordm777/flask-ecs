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