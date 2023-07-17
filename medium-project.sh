#!/bin/bash



# Obtém os argumentos
project_name=$1
current_path=$PWD

# Verifica se o diretório de destino existe, se não, cria-o
if [ ! -d "$project_name" ]; then
    mkdir -p "$project_name"
fi

# sessao para criar pastas
mkdir "$current_path/$project_name/modules"
mkdir "$current_path/$project_name/modules/network"
mkdir "$current_path/$project_name/prod"
mkdir "$current_path/$project_name/stage"

# sessao para criar arquivos
echo 'module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = var.name

  cidr = var.cidr

  public_subnets = var.public_subnets
}
' > "$current_path/$project_name/modules/network/main.tf"

echo 'output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
' > "$current_path/$project_name/modules/network/outputs.tf"

echo 'variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  type        = string
  default     = "0.0.0.0/0"
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}
' > "$current_path/$project_name/modules/network/variables.tf"


echo 'provider "aws" {
  region = "eu-west-1"

  allowed_account_ids = var.allowed_account_ids
}

terraform {
  backend "s3" {
    key = "medium-terraform/prod/terraform.tfstate"
    # ...
  }
}

module "network" {
  source = "../modules/network"

  name = var.name

  cidr = var.cidr
  azs  = var.azs

  public_subnets = var.public_subnets
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  #...
}' > "$current_path/$project_name/prod/main.tf"
echo 'output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}
' > "$current_path/$project_name/prod/outputs.tf"
echo 'variable "allowed_account_ids" {
  description = "List of allowed AWS account ids where resources can be created"
  type        = list(string)
  default     = []
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  type        = string
  default     = "0.0.0.0/0"
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}
' > "$current_path/$project_name/prod/variables.tf"
echo 'allowed_account_ids = ["111111111111"]

name = "my-prod-vpc"

cidr = "10.10.0.0/16"

azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

public_subnets = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]
' > "$current_path/$project_name/prod/terraform.tfvars"

echo 'provider "aws" {
  region = "eu-west-1"

  allowed_account_ids = var.allowed_account_ids
}

terraform {
  backend "s3" {
    key = "medium-terraform/stage/terraform.tfstate"
    # ...
  }
}

module "network" {
  source = "../modules/network"

  name = var.name

  cidr = var.cidr
  azs  = var.azs

  public_subnets = var.public_subnets
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  #...
}' > "$current_path/$project_name/stage/main.tf"
echo 'output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}
' > "$current_path/$project_name/stage/outputs.tf"
echo 'variable "allowed_account_ids" {
  description = "List of allowed AWS account ids where resources can be created"
  type        = list(string)
  default     = []
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  type        = string
  default     = "0.0.0.0/0"
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}
' > "$current_path/$project_name/stage/variables.tf"
echo 'allowed_account_ids = ["222222222222"]

name = "my-stage-vpc"

cidr = "10.20.0.0/16"

azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

public_subnets = ["10.20.101.0/24", "10.20.102.0/24", "10.20.103.0/24"]
' > "$current_path/$project_name/stage/terraform.tfvars"

#Cria o arquivo .gitignore dentro do projeto
echo '# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files, which are likely to contain sensitive data, such as
# password, private keys, and other secrets. These should not be part of version 
# control as they are data points which are potentially sensitive and subject 
# to change depending on the environment.
*.tfvars
*.tfvars.json

# Ignore override files as they are usually used to override resources locally and so
# are not checked in
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Include override files you do wish to add to version control using negated pattern
# !example_override.tf

# Include tfplan files to ignore the plan output of command: terraform plan -out=tfplan
# example: *tfplan*

# Ignore CLI configuration files
.terraformrc
terraform.rc
' > "$current_path/$project_name/.gitignore"
echo "# Medium-size infrastructure with Terraform

Source: [https://github.com/antonbabenko/terraform-best-practices/tree/master/examples/medium-terraform](https://github.com/antonbabenko/terraform-best-practices/tree/master/examples/medium-terraform)

This example contains code as an example of structuring Terraform configurations for a medium-size infrastructure which uses:

* 2 AWS accounts
* 2 separate environments (`prod` and `stage` which share nothing). Each environment lives in a separate AWS account
* Each environment uses a different version of the off-the-shelf infrastructure module (`alb`) sourced from [Terraform Registry](https://registry.terraform.io/)
* Each environment uses the same version of an internal module `modules/network` since it is sourced from a local directory.

{% hint style="success" %}
* Perfect for projects where infrastructure is logically separated (separate AWS accounts)
* Good when there is no is need to modify resources shared between AWS accounts (one environment = one AWS account = one state file)
* Good when there is no need in the orchestration of changes between the environments
* Good when infrastructure resources are different per environment on purpose and can't be generalized (eg, some resources are absent in one environment or in some regions)
{% endhint %}

{% hint style="warning" %}
As the project grows, it will be harder to keep these environments up-to-date with each other. Consider using infrastructure modules (off-the-shelf or internal) for repeatable tasks.
{% endhint %}

##
" > "$current_path/$project_name/README.md"

echo "$project_name created successfully"