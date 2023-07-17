#!/bin/bash



# Obtém os argumentos
project_name=$1
current_path=$PWD

# Verifica se o diretório de destino existe, se não, cria-o
if [ ! -d "$project_name" ]; then
    mkdir -p "$project_name"
fi

# sessao para criar pastas

# sessao para criar arquivos
echo 'locals {
  create_vpc = var.vpc_id == ""
}

data "aws_vpc" "selected" {
  count = local.create_vpc ? 0 : 1

  id = var.vpc_id
}

resource "aws_vpc" "this" {
  count = local.create_vpc ? 1 : 0

  cidr_block = var.cidr
}

resource "aws_internet_gateway" "this" {
  vpc_id = try(data.aws_vpc.selected[0].id, aws_vpc.this[0].id)
}
' > "$current_path/$project_name/main.tf"
echo 'output "vpc_id" {
  description = "ID of the VPC"
  value       = try(data.aws_vpc.selected[0].id, aws_vpc.this[0].id)
}
' > "$current_path/$project_name/outputs.tf"




echo 'variable "vpc_id" {
  description = "Existing VPC to use (specify this, if you dont want to create new VPC)"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  type        = string
  default     = "0.0.0.0/0"
}
' > "$current_path/$project_name/variables.tf"




echo '# Specify existing VPC ID to use it:
# vpc_id = "vpc-9651acf1"

# Or, create a new VPC:
name = "my-vpc"

cidr = "10.10.0.0/16"

azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

public_subnets = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]
' > "$current_path/$project_name/terraform.tfvars"

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

echo "# Small-size infrastructure with Terraform

Source: [https://github.com/antonbabenko/terraform-best-practices/tree/master/examples/small-terraform](https://github.com/antonbabenko/terraform-best-practices/tree/master/examples/small-terraform)

This example contains code as an example of structuring Terraform configurations for a small-size infrastructure, where no external dependencies are used.

{% hint style="success" %}
* Perfect to get started and refactor as you go
* Perfect for small resource modules
* Good for small and linear infrastructure modules (eg, [terraform-aws-atlantis](https://github.com/terraform-aws-modules/terraform-aws-atlantis))
* Good for a small number of resources (fewer than 20-30)
{% endhint %}

{% hint style="warning" %}
Single state file for all resources can make the process of working with Terraform slow if the number of resources is growing (consider using an argument `-target` to limit the number of resources)
{% endhint %}
" > "$current_path/$project_name/README.md"

echo "$project_name created successfully"