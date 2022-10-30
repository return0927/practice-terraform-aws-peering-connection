##################################################
#                   INSTANCE                     #
##################################################
resource "aws_instance" "remote-instance" {
    provider = aws.remote

    ami = "ami-0091142fcd273792c" # amzn2-ami-hvm-2.0.20200207.1-x86_64-gp2
    instance_type = "t2.medium"
    key_name = aws_key_pair.remote-keypair.key_name
    subnet_id = aws_subnet.remote-private-subnet.id

    vpc_security_group_ids = [
        aws_security_group.remote-sg-private.id
    ]

    /* depends_on = [
      aws_internet_gateway.remote-igw
    ] */

    tags = {
        Name = "enak-ix-remote-instance"
    }

    user_data = <<EOF
#!/bin/bash
sudo mkdir -p /tmp/work/
sudo chmod 777 /tmp/work

cd /tmp/work/

sudo yum install -y squid patch

openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -extensions v3_ca -keyout squid-ca-key.pem -out squid-ca-cert.pem << EDT
KR
Daegu
Daegu
ENAK Corp
dev
*.ix.enak
lee@enak.kr
EDT

cat squid-ca-cert.pem squid-ca-key.pem >> squid-ca-cert-key.pem
sudo mkdir /etc/squid/certs
sudo mv squid-ca-cert-key.pem /etc/squid/certs/.
sudo chown squid:squid -R /etc/squid/certs

ssl_crtd=$(find /usr -type f -name ssl_crtd)
sudo $ssl_crtd -c -s /var/lib/ssl_db
sudo chown -R squid /var/lib/ssl_db

echo | tee squid.patch <<EDT
@@ -11,6 +11,9 @@
 acl localnet src fc00::/7       # RFC 4193 local private network range
 acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines

+acl localnet src 10.0.0.0/16
+acl localnet src 20.0.0.0/16
+
 acl SSL_ports port 443
 acl Safe_ports port 80         # http
 acl Safe_ports port 21         # ftp
@@ -56,7 +59,19 @@
 http_access deny all

 # Squid normally listens to port 3128
-http_port 3128
+http_port 3128 ssl-bump \\
+  cert=/etc/squid/certs/squid-ca-cert-key.pem \\
+  generate-host-certificates=on dynamic_cert_mem_cache_size=16MB
+
+https_port 3129 intercept ssl-bump \\
+  cert=/etc/squid/certs/squid-ca-cert-key.pem \\
+  generate-host-certificates=on dynamic_cert_mem_cache_size=16MB
+
+sslcrtd_program /usr/lib64/squid/ssl_crtd -s /var/lib/ssl_db -M 16MB
+acl step1 at_step SslBump1
+ssl_bump peek step1
+ssl_bump bump all
+ssl_bump splice all

 # Uncomment and adjust the following to add a disk cache directory." >> squid.patch
 #cache_dir ufs /var/spool/squid 100 16 256" >> squid.patch
EDT

sudo patch /etc/squid/squid.conf > /dev/null < squid.patch

sudo systemctl enable squid
sudo systemctl start squid
    EOF
}

resource "aws_security_group" "remote-sg-private" {
    provider = aws.remote

    name = "enak-ix-remote-sg-private"
    vpc_id = aws_vpc.remote-vpc.id

    ingress {
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "inbound"
        from_port = 0
        protocol = "-1"
        to_port = 0
    }

    egress {
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "outbound"
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
}

output "remote-instance-public-dns" {
  value = aws_instance.remote-instance.public_dns
}

output "remote-instance-public-ip" {
  value = aws_instance.remote-instance.public_ip
}

output "remote-instance-private-dns" {
  value = aws_instance.remote-instance.private_dns
}

output "remote-instance-private-ip" {
  value = aws_instance.remote-instance.private_ip
}
