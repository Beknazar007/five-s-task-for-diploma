provider "aws" {
  region = "us-east-1" 
}
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web-server-key" {
  key_name   = "web-server-key"
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_ssm_parameter" "web-server_key_pair" {
  name  = "web-server-key"
  type  = "SecureString"
  value = tls_private_key.example.private_key_pem
}
resource "aws_security_group" "web-server-sg" {
  name        = "web-server-sg"
  description = "Allow SSH, HTTP, HTTPS, and custom port inbound traffic"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web-server" {
  ami                    = "ami-04b70fa74e45c3917" # Specify your desired AMI
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnets[0] # Specify your subnet ID
  security_groups     = [aws_security_group.web-server-sg.id]
  key_name               = aws_key_pair.web-server-key.key_name
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
 sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              git clone https://github.com/Beknazar007/five-s-task-for-diploma.git
              cd five-s-task-for-diploma
              docker-compose up
              EOF

  tags = {
    Name = "web-server"
  }
}

resource "aws_lb" "web-server-lb" {
  name               = "web-server-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-server-sg.id]
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]] # Specify your public subnets
}

resource "aws_lb_target_group" "web-server-tg" {
  name     = "web-server-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id # Specify your VPC ID
}

resource "aws_lb_listener" "web-server-http-listener" {
  load_balancer_arn = aws_lb.web-server-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "web-server-https-listener" {
  load_balancer_arn = aws_lb.web-server-lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-server-tg.arn
  }
}


resource "aws_lb_target_group_attachment" "web-server-tg-attachment" {
  target_group_arn = aws_lb_target_group.web-server-tg.arn
  target_id        = aws_instance.web-server.id
  port             = 80
}
resource "tls_private_key" "ssl" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ssl" {
  private_key_pem = tls_private_key.ssl.private_key_pem

  subject {
    common_name  = aws_lb.web-server-lb.dns_name
    organization = "ACME SSLs, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.ssl.private_key_pem
  certificate_body = tls_self_signed_cert.ssl.cert_pem
}

output "instance_id" {
  value = aws_instance.web-server.id
}
