##################################################
#                   INSTANCE                     #
##################################################
resource "aws_instance" "near-instance" {
    provider = aws.near

    ami = "ami-0a93a08544874b3b7" # amzn2-ami-hvm-2.0.20200207.1-x86_64-gp2
    instance_type = "t2.medium"
    key_name = aws_key_pair.near-keypair.key_name
    subnet_id = aws_subnet.near-private-subnet.id

    vpc_security_group_ids = [
        aws_security_group.near-sg-private.id
    ]

    depends_on = [
      aws_subnet.near-private-subnet
    ]

    tags = {
        Name = "enak-ix-near-instance"
    }
}

resource "aws_security_group" "near-sg-public" {
    provider = aws.near

    name = "enak-ix-near-sg-public"
    vpc_id = aws_vpc.near-vpc.id

    ingress {
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "SSH"
        from_port = 22
        protocol = "tcp"
        to_port = 22
    }

    ingress {
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "Web"
        from_port = 80
        to_port = 80
        protocol = "tcp"
    }

    ingress {
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "Squid Proxy"
        from_port = 1080
        to_port = 1080
        protocol = "tcp"
    }

    ingress {
        cidr_blocks = [ "20.0.0.0/16" ]
        description = "All traffics from Singapore IX"
        from_port = 0
        to_port = 0
        protocol = "-1"
    }

    egress {
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "outbound"
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
}

resource "aws_security_group" "near-sg-private" {
  provider = aws.near

  name = "enak-ix-near-sg-private"
  vpc_id = aws_vpc.near-vpc.id

  ingress {
    cidr_blocks = [ "10.0.0.0/16" ]
    description = "All traffics from private subnet"
    from_port = 0
    protocol = "-1"
    to_port = 0
  }

  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "outbound"
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
}

output "near-instance-public-dns" {
  value = aws_instance.near-instance.public_dns
}

output "near-instance-public-ip" {
  value = aws_instance.near-instance.public_ip
}

output "near-instance-private-dns" {
  value = aws_instance.near-instance.private_dns
}

output "near-instance-private-ip" {
  value = aws_instance.near-instance.private_ip
}
