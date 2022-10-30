##################################################
#                   INSTANCE                     #
##################################################
resource "aws_instance" "near-instance-entrypoint" {
    provider = aws.near

    ami = "ami-0a93a08544874b3b7" # amzn2-ami-hvm-2.0.20200207.1-x86_64-gp2
    instance_type = "t2.medium"
    key_name = aws_key_pair.near-keypair.key_name
    subnet_id = aws_subnet.near-public-subnet.id

    vpc_security_group_ids = [
        aws_security_group.near-sg-public.id
    ]

    depends_on = [
      aws_internet_gateway.near-igw
    ]

    tags = {
        Name = "enak-ix-near-instance-entrypoint"
    }
}

resource "aws_network_interface" "near-private-ni" {
    provider = aws.near

    subnet_id = aws_subnet.near-private-subnet.id

    attachment {
        instance = aws_instance.near-instance-entrypoint.id
        device_index = 1
    }
}

output "near-instance-entrypoint-public-dns" {
  value = aws_instance.near-instance-entrypoint.public_dns
}

output "near-instance-entrypoint-public-ip" {
  value = aws_instance.near-instance-entrypoint.public_ip
}

output "near-instance-entrypoint-private-dns" {
  value = aws_instance.near-instance-entrypoint.private_dns
}

output "near-instance-entrypoint-private-ip" {
  value = aws_instance.near-instance-entrypoint.private_ip
}
