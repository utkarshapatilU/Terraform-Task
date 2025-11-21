# -----------------------------
# Jenkins Security Group
# -----------------------------
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH & Jenkins UI"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Jenkins UI
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------
# Jenkins EC2 Instance
# -----------------------------
resource "aws_instance" "jenkins" {
  ami           = "ami-0c02fb55956c7d316"   # Amazon Linux 2
  instance_type = "t3.micro"  # Jenkins needs 2GB RAM; t2.micro will hang
  key_name      = aws_key_pair.devops_key.key_name

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = "Jenkins-Server"
  }
}
