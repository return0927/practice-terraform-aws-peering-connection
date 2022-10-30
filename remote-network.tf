##################################################
#                  Networking                    #
##################################################
data "aws_availability_zones" "remote-available" {
    provider = aws.remote
    state = "available"
}

## VPC
resource "aws_vpc" "remote-vpc" {
    provider = aws.remote

    cidr_block = "20.0.0.0/16"
    enable_dns_hostnames = true

    tags = { Name = "enak-ix-remote-vpc" }
}

resource "aws_internet_gateway" "remote-igw" {
    provider = aws.remote
    
    vpc_id = aws_vpc.remote-vpc.id

    tags = { Name = "enak-ix-remote-igw" }
}

## Public Subnet
resource "aws_subnet" "remote-public-subnet" {
    provider = aws.remote
    
    vpc_id = aws_vpc.remote-vpc.id
    cidr_block = "20.0.0.0/24"
    availability_zone = data.aws_availability_zones.remote-available.names[0]
    map_public_ip_on_launch = true

    tags = { Name = "enak-ix-remote-public-subnet" }
}

resource "aws_route_table" "remote-public-rt" {
    provider = aws.remote
    
    vpc_id = aws_vpc.remote-vpc.id

    tags = { Name = "enak-ix-remote-public-rt" }
}

resource "aws_route" "remote-public-rt" {
    provider = aws.remote
    
    route_table_id = aws_route_table.remote-public-rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.remote-igw.id
}

resource "aws_route_table_association" "remote-public-rt-ass" {
    provider = aws.remote
    
    subnet_id = aws_subnet.remote-public-subnet.id
    route_table_id = aws_route_table.remote-public-rt.id
}

resource "aws_eip" "remote-nat-ip" {
    provider = aws.remote

    vpc = true

    lifecycle {
        create_before_destroy = true
    }

    tags = { Name = "enai-ix-remote-eip" }
}

resource "aws_nat_gateway" "remote-nat-gw" {
    provider = aws.remote

    allocation_id = aws_eip.remote-nat-ip.id
    subnet_id = aws_subnet.remote-public-subnet.id

    tags = { Name = "enak-ix-remote-nat-gw" }
}

## Private Subnet
resource "aws_subnet" "remote-private-subnet" {
    provider = aws.remote

    vpc_id = aws_vpc.remote-vpc.id
    cidr_block = "20.0.1.0/24"
    availability_zone = data.aws_availability_zones.remote-available.names[0]
    
    tags = { Name = "enak-ix-remote-private-subnet" }
}

resource "aws_route_table" "remote-private-rt" {
    provider = aws.remote

    vpc_id = aws_vpc.remote-vpc.id

    tags = { Name = "enak-ix-remote-private-rt" }
}

resource "aws_route" "remote-private-rt-nat" {
    provider = aws.remote

    route_table_id = aws_route_table.remote-private-rt.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.remote-nat-gw.id
}

resource "aws_route_table_association" "remote-private-rt-ass" {
    provider = aws.remote

    subnet_id = aws_subnet.remote-private-subnet.id
    route_table_id = aws_route_table.remote-private-rt.id
}
