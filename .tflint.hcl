plugin "aws" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

config {
  call_module_type = "local"
  force  = false
}

# AWS Provider Configuration
rule "aws_instance_invalid_type" {
  enabled = true
}

rule "aws_instance_previous_type" {
  enabled = true
}

rule "aws_instance_invalid_ami" {
  enabled = true
}

rule "aws_route_not_specified_target" {
  enabled = true
}

rule "aws_route_specified_multiple_targets" {
  enabled = true
}

rule "aws_route_invalid_route_table" {
  enabled = true
}

rule "aws_route_invalid_vpc_peering_connection" {
  enabled = true
}

rule "aws_route_invalid_gateway" {
  enabled = true
}

rule "aws_route_invalid_nat_gateway" {
  enabled = true
}

rule "aws_route_invalid_network_interface" {
  enabled = true
}

rule "aws_route_invalid_instance" {
  enabled = true
}

rule "aws_route_invalid_vpc_endpoint" {
  enabled = true
}

rule "aws_route_invalid_carrier_gateway" {
  enabled = true
}

rule "aws_route_invalid_local_gateway" {
  enabled = true
}

rule "aws_route_invalid_vpc_peering_connection" {
  enabled = true
}

rule "aws_route_invalid_transit_gateway" {
  enabled = true
}

rule "aws_route_invalid_vpc_endpoint" {
  enabled = true
}

rule "aws_route_invalid_egress_only_internet_gateway" {
  enabled = true
}

rule "aws_route_invalid_network_interface" {
  enabled = true
}

rule "aws_route_invalid_instance" {
  enabled = true
}

rule "aws_route_invalid_nat_gateway" {
  enabled = true
}

rule "aws_route_invalid_gateway" {
  enabled = true
}

rule "aws_route_invalid_vpc_peering_connection" {
  enabled = true
}

rule "aws_route_invalid_route_table" {
  enabled = true
}

rule "aws_route_specified_multiple_targets" {
  enabled = true
}

rule "aws_route_not_specified_target" {
  enabled = true
}

rule "aws_instance_invalid_ami" {
  enabled = true
}

rule "aws_instance_previous_type" {
  enabled = true
}

rule "aws_instance_invalid_type" {
  enabled = true
}

# Terraform Configuration Rules
rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}

# Custom rules for GovCloud
rule "terraform_required_providers" {
  enabled = true
}

# Disable some rules for GovCloud specific configurations
rule "aws_route_invalid_gateway" {
  enabled = false
}

rule "aws_route_invalid_nat_gateway" {
  enabled = false
}
