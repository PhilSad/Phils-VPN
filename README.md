# Phils-VPN

This repository contains Terraform code to quickly set up a WireGuard VPN server on AWS.

Change the region in `provider "aws"` block in `main.tf` to change the VPN server location, default is eu-north-1 (Stockholm - Sweden).


```bash
# Install Terraform

sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform
touch ~/.bashrc
terraform -install-autocomplete
```

```bash
# install AWS CLI
sudo snap install aws-cli --classic
aws login
```

```bash
# Initialize Terraform and apply the configuration
terraform init
terraform apply
```

```bash
# After applying, retrieve the client configuration from the output
terraform output -raw client_configuration > client.conf
```