resource "aws_instance" "EKS-bastion" {
  ami                    = var.ami
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.EKS-public.id
  key_name               = "EKS"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -ex

    # Update system
    sudo apt update -y
    sudo apt install -y unzip curl

    # Install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    aws --version

    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    kubectl version --client

    # Configure kubeconfig for EKS cluster
    aws eks --region ap-south-1 update-kubeconfig --name EKS-Test
  EOF

  tags = {
    Name = "EKS-bastion"
  }
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.EKS-testing.id

  ingress {
    description = "SSH from my IP"
    from_port   = 0
    to_port     = 65000
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
