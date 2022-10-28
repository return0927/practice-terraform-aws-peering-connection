##################################################
#                  Networking                    #
##################################################
## VPC
resource "aws_vpc" "seoul-vpc" {
    provider = aws.seoul

    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true

    tags = { Name = "enak-ix-seoul-vpc" }
}

resource "aws_internet_gateway" "seoul-igw" {
    provider = aws.seoul
    
    vpc_id = aws_vpc.seoul-vpc.id

    tags = { Name = "enak-ix-seoul-igw" }
}

resource "aws_eip" "seoul-nat-ip" {
    provider = aws.seoul
    
    vpc = true

    lifecycle {
        create_before_destroy = true
    }

    tags = { Name = "enai-ix-seoul-eip" }
}

resource "aws_nat_gateway" "seoul-nat-gw" {
    provider = aws.seoul
    
    allocation_id = aws_eip.seoul-nat-ip.id
    subnet_id = aws_subnet.seoul-public-subnet.id

    tags = { Name = "enak-ix-seoul-nat-gw" }
}

## Public Subnet
resource "aws_subnet" "seoul-public-subnet" {
    provider = aws.seoul
    
    vpc_id = aws_vpc.seoul-vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-northeast-2a"
    map_public_ip_on_launch = true

    tags = { Name = "enak-ix-seoul-public-subnet" }
}

resource "aws_route_table" "seoul-public-rt" {
    provider = aws.seoul
    
    vpc_id = aws_vpc.seoul-vpc.id

    tags = { Name = "enak-ix-seoul-public-rt" }
}

resource "aws_route" "seoul-public-rt" {
    provider = aws.seoul
    
    route_table_id = aws_route_table.seoul-public-rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.seoul-igw.id
}

resource "aws_route_table_association" "seoul-public-rt-ass" {
    provider = aws.seoul
    
    subnet_id = aws_subnet.seoul-public-subnet.id
    route_table_id = aws_route_table.seoul-public-rt.id
}

## Private Subnet
resource "aws_subnet" "seoul-private-subnet" {
    provider = aws.seoul
    
    vpc_id = aws_vpc.seoul-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-northeast-2a"

    tags = { Name = "enak-ix-seoul-private-subnet" }
}

resource "aws_route_table" "seoul-private-rt" {
    provider = aws.seoul
    
    vpc_id = aws_vpc.seoul-vpc.id

    tags = { Name = "enak-ix-seoul-private-rt" }
}

resource "aws_route" "seoul-ix-rt" {
    provider = aws.seoul
    route_table_id = aws_route_table.seoul-private-rt.id
    destination_cidr_block = "20.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.enak-ix-peering.id
}

resource "aws_route" "seoul-private-rt-nat" {
    provider = aws.seoul
    
    route_table_id = aws_route_table.seoul-private-rt.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.seoul-nat-gw.id
}

resource "aws_route_table_association" "seoul-private-rt-ass" {
    provider = aws.seoul
    
    subnet_id = aws_subnet.seoul-private-subnet.id
    route_table_id = aws_route_table.seoul-private-rt.id
}
