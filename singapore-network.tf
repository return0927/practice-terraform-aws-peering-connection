##################################################
#                  Networking                    #
##################################################
## VPC
resource "aws_vpc" "singapore-vpc" {
    provider = aws.singapore

    cidr_block = "20.0.0.0/16"
    enable_dns_hostnames = true

    tags = { Name = "enak-ix-singapore-vpc" }
}

resource "aws_internet_gateway" "singapore-igw" {
    provider = aws.singapore
    
    vpc_id = aws_vpc.singapore-vpc.id

    tags = { Name = "enak-ix-singapore-igw" }
}

## Private Subnet
resource "aws_subnet" "singapore-private-subnet" {
    provider = aws.singapore

    vpc_id = aws_vpc.singapore-vpc.id
    cidr_block = "20.0.1.0/24"
    availability_zone = "ap-southeast-1a"
    
    tags = { Name = "enak-ix-singapore-private-subnet" }
}

resource "aws_eip" "singapore-nat-ip" {
    provider = aws.singapore

    vpc = true

    lifecycle {
        create_before_destroy = true
    }

    tags = { Name = "enai-ix-singapore-eip" }
}

resource "aws_nat_gateway" "singapore-nat-gw" {
    provider = aws.singapore

    allocation_id = aws_eip.singapore-nat-ip.id
    subnet_id = aws_subnet.singapore-private-subnet.id

    tags = { Name = "enak-ix-singapore-nat-gw" }
}

resource "aws_route_table" "singapore-private-rt" {
    provider = aws.singapore

    vpc_id = aws_vpc.singapore-vpc.id

    tags = { Name = "enak-ix-singapore-private-rt" }
}

resource "aws_route" "singapore-private-rt-nat" {
    provider = aws.singapore

    route_table_id = aws_route_table.singapore-private-rt.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.singapore-nat-gw.id
}

resource "aws_route_table_association" "singapore-private-rt-ass" {
    provider = aws.singapore

    subnet_id = aws_subnet.singapore-private-subnet.id
    route_table_id = aws_route_table.singapore-private-rt.id
}
