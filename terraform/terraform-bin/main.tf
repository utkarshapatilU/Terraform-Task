provider "aws" {
  region = "us-east-1"
}

# Variable declaration with default path to your public key
variable "public_key_path" {
  type        = string
  description = "Path to SSH public key"
  default     = "~/.ssh/devops_key.pub"  # <-- replace with your actual path
}

# AWS Key Pair using the public key
resource "aws_key_pair" "devops_key" {
  key_name   = "devops_key"
  public_key = file(var.public_key_path)
}

# Security group for web server
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.devops_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "DevOps-EC2"
  }
}

# Output the public IP
output "web_instance_ip" {
  value = aws_instance.web.public_ip
}
