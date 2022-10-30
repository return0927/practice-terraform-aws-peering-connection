resource "aws_route53_zone" "main" {
    name = "ix.enak"

    vpc {
        vpc_region = data.aws_region.near.name
        vpc_id = aws_vpc.near-vpc.id
    }

    vpc {
        vpc_region = data.aws_region.remote.name
        vpc_id = aws_vpc.remote-vpc.id
    }
}

resource "aws_route53_record" "near-entrypoint" {
    zone_id = aws_route53_zone.main.id

    name = "near-entrypoint"
    type = "CNAME"
    ttl = 5
    records = [ aws_instance.near-instance-entrypoint.private_dns ]
}

resource "aws_route53_record" "near" {
    zone_id = aws_route53_zone.main.id

    name = "near"
    type = "CNAME"
    ttl = 5
    records = [ aws_instance.near-instance.private_dns ]
}

resource "aws_route53_record" "remote" {
    zone_id = aws_route53_zone.main.id

    name = "remote"
    type = "CNAME"
    ttl = 5
    records = [ aws_instance.remote-instance.private_dns ]
}

output "route53-near" {
    value = aws_route53_record.near.records
}

output "route53-near-entrypoint" {
    value = aws_route53_record.near-entrypoint.records
}

output "route53-remote" {
    value = aws_route53_record.remote.records
}
