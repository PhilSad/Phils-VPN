# Phils-VPN

This repository contains Terraform code to quickly set up a WireGuard VPN server on AWS.

Change the region in `provider "aws"` block in `main.tf` to change the VPN server location, default is eu-north-1 (Stockholm - Sweden).


## Motivation
I wanted a free and simple way to set up a VPN server for when I want to change my IP location. 

## Prerequisites
- An AWS account with appropriate permissions to create EC2 instances in your chosen region.
- Terraform installed on your local machine.
- AWS CLI installed and configured with your credentials.

## Usage
```bash
# Initialize Terraform and apply the configuration
terraform init
terraform apply
```

```bash
# After applying, retrieve the client configuration from the output
terraform output -raw client_configuration > client.conf
```

```bash
# Once you're done using the VPN, destroy the resources to avoid incurring costs
terraform destroy
```