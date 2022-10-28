##################################################
#                      VPC                       #
##################################################
resource "aws_instance" "seoul-instance" {
    provider = aws.seoul

    ami = "ami-0a93a08544874b3b7" # amzn2-ami-hvm-2.0.20200207.1-x86_64-gp2
    instance_type = "t2.medium"
    key_name = aws_key_pair.keypair.key_name
    subnet_id = aws_subnet.seoul-public-subnet.id

    vpc_security_group_ids = [
        aws_security_group.seoul-sg-public.id
    ]

    depends_on = [
      aws_internet_gateway.seoul-igw
    ]

    tags = {
        Name = "enak-ix-seoul-instance"
    }
}

resource "aws_security_group" "seoul-sg-public" {
    provider = aws.seoul

    name = "enak-ix-seoul-sg-public"
    vpc_id = aws_vpc.seoul-vpc.id

    ingress {
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "SSH"
        from_port = 22
        protocol = "tcp"
        to_port = 22
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

resource "aws_network_interface" "seoul-private-ni" {
    provider = aws.seoul

    subnet_id = aws_subnet.seoul-private-subnet.id
    
    attachment {
      instance = aws_instance.seoul-instance.id
      device_index = 1
    }
}

output "seoul-instance-public-dns" {
  value = aws_instance.seoul-instance.public_dns
}

output "seoul-instance-public-ip" {
  value = aws_instance.seoul-instance.public_ip
}

output "seoul-instance-private-ip" {
  value = aws_instance.seoul-instance.private_ip
}
