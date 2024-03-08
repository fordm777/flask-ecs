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
