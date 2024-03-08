# Project To Create Flask app using ECS and Fargate #

The solution was done using the following:

1. Terraform
2. Docker
3. AWS VPC and Endpoints
4. AWS ECS and Fargate
5. AWS ALB
6. AWS ECR

Download the files from the Git Repository
* https://github.com/fordm777/flask-ecs.git
 
```bash
git clone https://github.com/fordm777/flask-ecs.git
cd flask-ecs
```

Modify the file `terraform.tfvars` and update the variables
* app_name
* aws_account
* aws_region
* aws_profile

Then run the following commands

```bash
terraform init
terraform plan
terraform apply
```
Once the process finishes it will output the URL for the ALB.  Copy and paste the URL in your browser to access the sample application.

```bash
Apply complete! Resources: 35 added, 0 changed, 0 destroyed.

Outputs:

URL = "http://flask-test-public-alb-619216788.us-east-1.elb.amazonaws.com/"
```

## A breif explaination of the solution

1. The ECR repository was create using MUTABLE.  So that you can rebuild the Docker image and upload using the same tag.  Other option would be to use IMMUTABLE and change the tag for every build.
2. The process builds a Docker image and uploads to AWS ECR.
3. A VPC is created with 2 Public subnets and 2 Private subnets.
4. Several VPC endpoints will be created to avoid creating and using a NAT gateway and keep the private subnets secure.
5. The Fargate service is created in a private subnet for a secure configuration.
6. The Cluster is configured using FARGATE_SPOT to save on costs.
7. The security group for the ECS tasks to allow traffic ONLY from the ALB security group.
8. This could be done automatically via Jenkins or Bamboo using their build numbers.
9. Since this was just a Python script, there was no need to use Jenkins and or Atlassian Bamboo, etc.

## The following files were used

1. `provider.tf` - Provider configuration
2. `docker.tf` - create ECR and build docker image and push image to ECR
3. `network.tf` - Create VPC, Subnets, Internet Gateway, Route Tables, and Endpoints
4. `execution-role.tf` - Create execution roles for Fargate services
5. `ecs.tf` - Create the ECS cluster, task-definition, service, and log group in CloudWatch
6. `variables.tf` - List of variables
7. `terraform.tfvars` - Default variables for runtime

