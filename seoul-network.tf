##################################################
#                  Networking                    #
##################################################
data "aws_availability_zones" "near-available" {
    provider = aws.near
    state = "available"
}

## VPC
resource "aws_vpc" "near-vpc" {
    provider = aws.near

    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true

    tags = { Name = "enak-ix-near-vpc" }
}

resource "aws_internet_gateway" "near-igw" {
    provider = aws.near
    
    vpc_id = aws_vpc.near-vpc.id

    tags = { Name = "enak-ix-near-igw" }
}

## Public Subnet
resource "aws_subnet" "near-public-subnet" {
    provider = aws.near
    
    vpc_id = aws_vpc.near-vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = data.aws_availability_zones.near-available.names[0]
    map_public_ip_on_launch = true

    tags = { Name = "enak-ix-near-public-subnet" }
}

resource "aws_route_table" "near-public-rt" {
    provider = aws.near
    
    vpc_id = aws_vpc.near-vpc.id

    tags = { Name = "enak-ix-near-public-rt" }
}

resource "aws_route" "near-public-rt" {
    provider = aws.near
    
    route_table_id = aws_route_table.near-public-rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.near-igw.id
}

resource "aws_route_table_association" "near-public-rt-ass" {
    provider = aws.near
    
    subnet_id = aws_subnet.near-public-subnet.id
    route_table_id = aws_route_table.near-public-rt.id
}

## Private Subnet
resource "aws_subnet" "near-private-subnet" {
    provider = aws.near

    vpc_id = aws_vpc.near-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = data.aws_availability_zones.near-available.names[0]
    
    tags = { Name = "enak-ix-near-private-subnet" }
}

resource "aws_route_table" "near-private-rt" {
    provider = aws.near

    vpc_id = aws_vpc.near-vpc.id

    tags = { Name = "enak-ix-near-private-rt" }
}

resource "aws_route_table_association" "near-private-rt-ass" {
    provider = aws.near

    subnet_id = aws_subnet.near-private-subnet.id
    route_table_id = aws_route_table.near-private-rt.id
}
