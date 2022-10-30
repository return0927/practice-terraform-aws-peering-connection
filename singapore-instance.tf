##################################################
#                   INSTANCE                     #
##################################################
resource "aws_instance" "remote-instance" {
    provider = aws.remote

    ami = "ami-094bbd9e922dc515d" # amzn2-ami-hvm-2.0.20200207.1-x86_64-gp2
    instance_type = "t2.medium"
    key_name = aws_key_pair.keypair.key_name
    subnet_id = aws_subnet.remote-private-subnet.id

    vpc_security_group_ids = [
        aws_security_group.remote-sg-private.id
    ]

    /* depends_on = [
      aws_internet_gateway.remote-igw
    ] */

    tags = {
        Name = "enak-ix-remote-instance"
    }
}

resource "aws_security_group" "remote-sg-private" {
    provider = aws.remote

    name = "enak-ix-remote-sg-private"
    vpc_id = aws_vpc.remote-vpc.id

    ingress {
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "inbound"
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

output "remote-instance-public-dns" {
  value = aws_instance.remote-instance.public_dns
}

output "remote-instance-public-ip" {
  value = aws_instance.remote-instance.public_ip
}

output "remote-instance-private-dns" {
  value = aws_instance.remote-instance.private_dns
}

output "remote-instance-private-ip" {
  value = aws_instance.remote-instance.private_ip
}
