# vim aws_infra.tf

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "sl-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "sl-vpc"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.sl-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  depends_on = [aws_vpc.sl-vpc]
  tags = {
    Name = "sl-subnet"
  }
}

resource "aws_route_table" "sl-route-table" {
  vpc_id = aws_vpc.sl-vpc.id
  tags = {
    Name = "sl-route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.sl-route-table.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.sl-vpc.id
  depends_on = [aws_vpc.sl-vpc]
  tags = {
    Name = "sl-gw"
  }
}

resource "aws_route" "sl-route" {
  route_table_id         = aws_route_table.sl-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_security_group" "project-securitygroup" {
  name        = "project-securitygroup"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.sl-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project-securitygroup"
  }
}

resource "tls_private_key" "web-key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "app-key" {
  key_name   = "web-key"
  public_key = tls_private_key.web-key.public_key_openssh
}

resource "local_file" "web-key" {
  content  = tls_private_key.web-key.private_key_pem
  filename = "web-key.pem"
}

resource "aws_instance" "jenkins-master" {
  ami             = "ami-04b70fa74e45c3917"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet-1.id
  key_name        = "web-key"
  security_groups = [aws_security_group.project-securitygroup.id]
  tags = {
    Name = "Jenkins Master"
  }

  provisioner "file" {
    source      = "JenkinsMasterSetup.sh"
    destination = "JenkinsMasterSetup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x JenkinsMasterSetup.sh",
      "./JenkinsMasterSetup.sh"
    ]
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.web-key.private_key_pem
    host        = self.public_ip
  }
}

resource "aws_instance" "jenkins-slave" {
  ami             = "ami-04b70fa74e45c3917"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet-1.id
  key_name        = "web-key"
  security_groups = [aws_security_group.project-securitygroup.id]
  tags = {
    Name = "Jenkins Slave"
  }

  provisioner "file" {
    source      = "JenkinsSlaveSetup.sh"
    destination = "JenkinsSlaveSetup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x JenkinsSlaveSetup.sh",
      "./JenkinsSlaveSetup.sh"
    ]
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.web-key.private_key_pem
    host        = self.public_ip
  }
}

resource "aws_instance" "kubernetes-master" {
  ami             = "ami-04b70fa74e45c3917"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet-1.id
  key_name        = "web-key"
  security_groups = [aws_security_group.project-securitygroup.id]
  tags = {
    Name = "Kubernetes Master"
  }

  provisioner "file" {
    source      = "KubernatesMasterSetup.sh"
    destination = "KubernatesMasterSetup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x KubernatesMasterSetup.sh",
      "./KubernatesMasterSetup.sh"
    ]
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.web-key.private_key_pem
    host        = self.public_ip
  }
}

resource "aws_instance" "kubernetes-slave1" {
  ami             = "ami-04b70fa74e45c3917"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet-1.id
  key_name        = "web-key"
  security_groups = [aws_security_group.project-securitygroup.id]
  tags = {
    Name = "Kubernetes Slave 1"
  }

  provisioner "file" {
    source      = "KubernatesSlaveSetup.sh"
    destination = "KubernatesSlaveSetup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x KubernatesSlaveSetup.sh",
      "./KubernatesSlaveSetup.sh"
    ]
  }
 connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.web-key.private_key_pem
    host        = self.public_ip
  }
}

resource "aws_instance" "kubernetes-slave2" {
  ami             = "ami-04b70fa74e45c3917"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet-1.id
  key_name        = "web-key"
  security_groups = [aws_security_group.project-securitygroup.id]
  tags = {
    Name = "Kubernetes Slave 2"
  }

  provisioner "file" {
    source      = "KubernatesSlaveSetup.sh"
    destination = "KubernatesSlaveSetup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x KubernatesSlaveSetup.sh",
      "./KubernatesSlaveSetup.sh"
    ]
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.web-key.private_key_pem
    host        = self.public_ip
  }
}
