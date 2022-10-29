##################################################
#                      VPC                       #
##################################################
resource "aws_instance" "singapore-instance" {
    provider = aws.singapore

    ami = "ami-094bbd9e922dc515d" # amzn2-ami-hvm-2.0.20200207.1-x86_64-gp2
    instance_type = "t2.medium"
    key_name = aws_key_pair.keypair.key_name
    subnet_id = aws_subnet.singapore-public-subnet.id

    vpc_security_group_ids = [
        aws_security_group.singapore-sg-public.id
    ]

    depends_on = [
      aws_internet_gateway.singapore-igw
    ]

    tags = {
        Name = "enak-ix-singapore-instance"
    }
}

resource "aws_security_group" "singapore-sg-public" {
    provider = aws.singapore

    name = "enak-ix-singapore-sg-public"
    vpc_id = aws_vpc.singapore-vpc.id

    ingress {
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "SSH"
        from_port = 22
        protocol = "tcp"
        to_port = 22
    }

    ingress {
        cidr_blocks = [ "10.0.0.0/16" ]
        description = "All traffics from Seoul IX"
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

output "singapore-instance-public-dns" {
  value = aws_instance.singapore-instance.public_dns
}

output "singapore-instance-public-ip" {
  value = aws_instance.singapore-instance.public_ip
}

output "singapore-instance-private-dns" {
  value = aws_instance.singapore-instance.private_dns
}

output "singapore-instance-private-ip" {
  value = aws_instance.singapore-instance.private_ip
}
