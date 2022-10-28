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
}
