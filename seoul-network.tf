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

resource "aws_route_table_association" "seoul-private-rt-ass" {
    provider = aws.seoul

    subnet_id = aws_subnet.seoul-private-subnet.id
    route_table_id = aws_route_table.seoul-private-rt.id
}
