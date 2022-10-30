data "aws_region" "peering-region" {
  provider = aws.remote
}

resource "aws_vpc_peering_connection" "enak-ix-peering" {
    provider = aws.near

    peer_owner_id = aws_vpc.remote-vpc.owner_id
    peer_vpc_id = aws_vpc.remote-vpc.id
    peer_region = data.aws_region.peering-region
    # auto_accept = true

    vpc_id = aws_vpc.near-vpc.id

    tags = {
        Name = "enak-ix-peering"
    }
}

resource "aws_vpc_peering_connection_accepter" "enak-ix-peering-acc" {
    provider = aws.remote
    vpc_peering_connection_id = aws_vpc_peering_connection.enak-ix-peering.id
    auto_accept = true

    depends_on = [
      aws_vpc_peering_connection.enak-ix-peering
    ]
}

resource "aws_vpc_peering_connection_options" "enak-ix-peering-near-opt" {
    provider = aws.near
    vpc_peering_connection_id = aws_vpc_peering_connection.enak-ix-peering.id
    
    requester {
        allow_remote_vpc_dns_resolution = true
    }

    depends_on = [
      aws_vpc_peering_connection_accepter.enak-ix-peering-acc
    ]
}

resource "aws_vpc_peering_connection_options" "enak-ix-peering-remote-opt" {
    provider = aws.remote
    vpc_peering_connection_id = aws_vpc_peering_connection.enak-ix-peering.id
    
    accepter {
        allow_remote_vpc_dns_resolution = true
    }

    depends_on = [
      aws_vpc_peering_connection_accepter.enak-ix-peering-acc
    ]
}

resource "aws_route" "near-ix-rt" {
    provider = aws.near
    route_table_id = aws_route_table.near-private-rt.id
    destination_cidr_block = "20.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.enak-ix-peering.id

    depends_on = [
      aws_vpc_peering_connection_accepter.enak-ix-peering-acc
    ]
}

resource "aws_route" "remote-ix-rt" {
    provider = aws.remote
    route_table_id = aws_route_table.remote-private-rt.id
    destination_cidr_block = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.enak-ix-peering.id

    depends_on = [
      aws_vpc_peering_connection_accepter.enak-ix-peering-acc
    ]
}

output "enak-ix-peering-connection" {
    value = aws_vpc_peering_connection.enak-ix-peering.accept_status
}
