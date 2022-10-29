##################################################
#                   INSTANCE                     #
##################################################
resource "aws_instance" "seoul-instance-entrypoint" {
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
        Name = "enak-ix-seoul-instance-entrypoint"
    }
}

resource "aws_network_interface" "seoul-private-ni" {
    provider = aws.seoul

    subnet_id = aws_subnet.seoul-private-subnet.id

    attachment {
        instance = aws_instance.seoul-instance-entrypoint.id
        device_index = 1
    }
}
