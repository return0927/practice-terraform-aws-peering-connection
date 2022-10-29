resource "aws_vpc_peering_connection" "enak-ix-peering" {
    provider = aws.seoul

    peer_owner_id = aws_vpc.singapore-vpc.owner_id
    peer_vpc_id = aws_vpc.singapore-vpc.id
    peer_region = "ap-southeast-1"
    # auto_accept = true

    vpc_id = aws_vpc.seoul-vpc.id

    tags = {
        Name = "enak-ix-peering"
    }
}

resource "aws_vpc_peering_connection_accepter" "enak-ix-peering-acc" {
    provider = aws.singapore
    vpc_peering_connection_id = aws_vpc_peering_connection.enak-ix-peering.id
    auto_accept = true

    depends_on = [
      aws_vpc_peering_connection.enak-ix-peering
    ]
}

resource "aws_vpc_peering_connection_options" "enak-ix-peering-seoul-opt" {
    provider = aws.seoul
    vpc_peering_connection_id = aws_vpc_peering_connection.enak-ix-peering.id
    
    requester {
        allow_remote_vpc_dns_resolution = true
    }

    depends_on = [
      aws_vpc_peering_connection_accepter.enak-ix-peering-acc
    ]
}

resource "aws_vpc_peering_connection_options" "enak-ix-peering-singapore-opt" {
    provider = aws.singapore
    vpc_peering_connection_id = aws_vpc_peering_connection.enak-ix-peering.id
    
    accepter {
        allow_remote_vpc_dns_resolution = true
    }

    depends_on = [
      aws_vpc_peering_connection_accepter.enak-ix-peering-acc
    ]
}

resource "aws_route" "seoul-ix-rt" {
    provider = aws.seoul
    route_table_id = aws_route_table.seoul-private-rt.id
    destination_cidr_block = "20.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.enak-ix-peering.id

    depends_on = [
      aws_vpc_peering_connection_accepter.enak-ix-peering-acc
    ]
}

resource "aws_route" "singapore-ix-rt" {
    provider = aws.singapore
    route_table_id = aws_route_table.singapore-private-rt.id
    destination_cidr_block = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.enak-ix-peering.id

    depends_on = [
      aws_vpc_peering_connection_accepter.enak-ix-peering-acc
    ]
}

output "enak-ix-peering-connection" {
    value = aws_vpc_peering_connection.enak-ix-peering.accept_status
}
