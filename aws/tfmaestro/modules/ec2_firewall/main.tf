data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name" 
    values = ["${var.environment}-vpc"]
  }
}

data "aws_subnet" "public_subnet" {
  filter {
    name   = "tag:Name" 
    values = ["${var.environment}-public-subnet-01"]
  }
  vpc_id = data.aws_vpc.vpc.id
}

resource "aws_security_group" "firewall_rules" {
  name        = "${var.network_name}-allow"
  description = "Allow rules for ${var.network_name}"
  vpc_id      = data.aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.allow_firewall_rules
    content {
      from_port   = (ingress.value.protocol == "icmp") ? 0 : tonumber(lookup(ingress.value, "ports", [0])[0])
      to_port     = (ingress.value.protocol == "icmp") ? 0 : tonumber(lookup(ingress.value, "ports", [0])[0])
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.source_ip_ranges
      description = ingress.value.description
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ec2-security-group"
  }
}

resource "aws_network_interface" "main" {
  for_each      = var.ec2_instances
  subnet_id     = data.aws_subnet.public_subnet.id
  private_ips   = [cidrhost(var.subnet_cidr, each.value.ip_host)]
  security_groups = [aws_security_group.firewall_rules.id]
}

resource "aws_key_pair" "kasia_key" {
  key_name   = "kasia-tf"
  public_key = file("${path.module}/ssh/kasia_key.pub")
}

resource "aws_instance" "main" {
  for_each            = var.ec2_instances
  ami                 = var.ami_id
  instance_type       = each.value.instance_type
  availability_zone   = each.value.availability_zone
  key_name            = aws_key_pair.kasia_key.key_name

  tags = {
    Name        = each.key
    Description = try(each.value.instance_description, null)
  }

  user_data = <<-EOF
              #!/bin/bash

              echo "Aktualizacja pakietów..."
              apt-get update -y

              echo "Instalacja narzędzi do analizy sieci (net-tools)..."
              apt-get install -y net-tools

              echo "Czekam na zakończenie uruchamiania systemu..."
              sleep 60

              echo "Instalacja Nginx..."
              sudo apt-get install -y nginx

              echo "Tworzenie strony /health dla health check..."
              sudo echo -e "server {\n    listen 80;\n\n    location / {\n        root /var/www/html;\n        index index.html;\n    }\n\n    location /health {\n        add_header Content-Type text/plain;\n        return 200 'OK';\n    }\n}" > /etc/nginx/sites-available/default

              echo "Włączanie i uruchamianie Nginx..."
              sudo systemctl enable nginx
              sudo systemctl start nginx

              echo "Nginx powinien teraz działać. Sprawdzanie statusu..."
              sudo systemctl status nginx
              EOF

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.main[each.key].id
  }
}
