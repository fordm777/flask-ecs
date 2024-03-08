##
## Create the VPC
##
data "aws_availability_zones" "available" { state = "available" }
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5.3"

  name                 = var.app_name
  # Span subnetworks across 2 avalibility zones
  azs                  = slice(data.aws_availability_zones.available.names, 0, 2) 
  cidr                 = var.aws_cdir
  create_vpc           = true
  create_igw           = true # Expose public subnetworks to the Internet
  private_subnets      = var.aws_private_subnets
  public_subnets       = var.aws_public_subnets
  enable_dns_hostnames = true
  enable_dns_support   = true
  #enable_nat_gateway   = var.aws_enable_nat # Hide private subnetworks behind NAT Gateway
  #single_nat_gateway   = true
}

module "vpc_endpoints" {
source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
version = "5.5.3"

vpc_id = module.vpc.vpc_id
create_security_group      = true
security_group_name_prefix = "${var.app_name}-vpc-endpoints-"
security_group_description = "VPC endpoint security group"
security_group_rules = {
    ingress_https = {
        description = "HTTPS from VPC"
        cidr_blocks = [module.vpc.vpc_cidr_block]
    }
}

endpoints = {
    # s3 = {
    #     service             = "s3"
        
    #     private_dns_enabled = true
    #     dns_options = {
    #         private_dns_only_for_inbound_resolver_endpoint = false
    #     }
    #     policy              = data.aws_iam_policy_document.generic_endpoint_policy.json

    #     tags = { Name = "${var.app_name}-s3-vpc-endpoint"}
    # },
    ecs = {
      service             = "ecs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags = { Name = "${var.app_name}-ecs-vpc-endpoint"}
    },
    ecs_telemetry = {
      create              = false
      service             = "ecs-telemetry"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags = { Name = "${var.app_name}-ecs-telemetry-vpc-endpoint"}
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags = { Name = "${var.app_name}-ecr-api-vpc-endpoint"}
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags = { Name = "${var.app_name}-ecr-dkr-vpc-endpoint"}
    },
    logs = {
      service             = "logs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags = { Name = "${var.app_name}-logs-vpc-endpoint"}
    },
    secretsmanager = {
      service             = "secretsmanager"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags = { Name = "${var.app_name}-secrets-mgr-vpc-endpoint"}
    },
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = flatten([module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
  tags = { Name = "${var.app_name}-s3-vpc-endpoint"}
}

################################################################################
# Supporting Resources
################################################################################
data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpc"
      values = [module.vpc.vpc_id]
    }
  }
}
