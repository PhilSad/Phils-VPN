provider "aws" {
  region = "eu-north-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name = "free-tier-eligible"
    values = ["true"]
}

  owners = ["099720109477"] # Canonical
}

resource "wireguard_asymmetric_key" "wg_client_keypair" {}
resource "wireguard_asymmetric_key" "wg_server_keypair" {}


resource "aws_security_group" "allow_tls_ssh_wireguard" {
  name        = "allow_tls_ssh_wireguard"
  description = "Allow TLS, SSH, and WireGuard inbound traffic and all outbound traffic"

  tags = {
    Name = "allow_tls_ssh_wireguard"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls_ssh_wireguard.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
  security_group_id = aws_security_group.allow_tls_ssh_wireguard.id
  cidr_ipv6         = "::/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


resource "aws_vpc_security_group_ingress_rule" "allow_wireguard" {
  security_group_id = aws_security_group.allow_tls_ssh_wireguard.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 47154
  ip_protocol       = "udp"
  to_port           = 47154
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_tls_ssh_wireguard.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls_ssh_wireguard.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_tls_ssh_wireguard.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
  


resource "aws_instance" "vpn_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "vpn-terraform"
  }

  security_groups = [aws_security_group.allow_tls_ssh_wireguard.name]

  user_data = templatefile("./setup_wireguard_server.tftpl", {
    server_private_key = wireguard_asymmetric_key.wg_server_keypair.private_key
    server_public_key  = wireguard_asymmetric_key.wg_server_keypair.public_key
    client_public_key  = wireguard_asymmetric_key.wg_client_keypair.public_key
  })
}


output "client_configuration" {
  value = <<EOT
  
  [Interface]
  PrivateKey = ${nonsensitive(wireguard_asymmetric_key.wg_client_keypair.private_key)}
  Address = 10.0.0.2/32
  DNS = 1.1.1.1

  [Peer]
  PublicKey = ${wireguard_asymmetric_key.wg_server_keypair.public_key}
  Endpoint = ${aws_instance.vpn_server.public_ip}:47154
  AllowedIPs = 0.0.0.0/0
  
  EOT
}
