# Project To Create Flask app using ECS and Fargate #

The solution was done using the following:

1. Terraform
2. Docker
3. AWS ECS Fargate
4. AWS ALB
5. AWS ECR

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

1. The Fargate service was created in a public subnet.  Why? To save time and reduce my costs in my AWS account.  In order to create the service in a private subnet, I would need to create Endpoints or create a NAT gateway for the service to get the docker image from ECR.
2. I set the security group for the ECS tasks to allow traffic ONLY from the ALB security group.  Again, it would still be better to create the Fargate in the private subnet.
3. The ECR repository was create using MUTABLE.  So that you can rebuild the Docker image and upload using the same tag.  Other option would be to use IMMUTABLE and change the tag for every build.  This could be done automatically via Jenkins or Bamboo using their build numbers.
4. Since this was just a Python script, there was no need to use Jenkins and or Atlassian Bamboo, etc.

## The following files were used

1. `provider.tf`
2. `docker.tf`
3. `network.tf`
4. `execution-role.tf`
5. `ecs.tf`
6. `variables.tf`
7. `terraform.tfvars`

