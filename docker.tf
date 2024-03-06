##
## Create the ECR Repository to store the Docker image
##
module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 1.6.0"

  repository_force_delete = true
  repository_image_tag_mutability = "MUTABLE"
  repository_name         = var.app_name
  repository_lifecycle_policy = jsonencode({
    rules = [{
      action       = { type = "expire" }
      description  = "Delete all images except 1"
      rulePriority = 1
      selection = {
        countNumber = 1
        countType   = "imageCountMoreThan"
        tagStatus   = "any"
      }
    }]
  })
}

##
## Define vars for building and pushing Docker image
##
locals {

  # ECR docker registry URI
  aws_ecr = "${var.aws_account}.dkr.ecr.${var.aws_region}.amazonaws.com"
  aws_ecr_uri = "${local.aws_ecr}/${var.app_name}"

  dkr_img_src_path   = "${path.module}/Code"
  dkr_img_src_sha256 = sha256(join("", [for f in fileset(".", "${local.dkr_img_src_path}/**") : file(f)]))

  dkr_build_cmd = <<-EOT
      cd Code

      docker build -t ${local.aws_ecr_uri}:${var.image_tag} -f ./Dockerfile .

      aws --profile ${var.aws_profile} ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${local.aws_ecr}

      docker push ${local.aws_ecr_uri}:${var.image_tag}
    EOT
}


# local-exec for build and push of docker image
# Triggers if any changes to the image files
resource "null_resource" "build_push_dkr_img" {
  triggers = {
    detect_docker_source_changes = var.force_image_rebuild == true ? timestamp() : local.dkr_img_src_sha256
  }
  provisioner "local-exec" {
    command = local.dkr_build_cmd
  }
}