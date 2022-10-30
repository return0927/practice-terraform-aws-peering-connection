provider "aws" {
  alias = "near"
  region = "ap-northeast-2"
}

provider "aws" {
  alias = "remote"
  region = "us-west-2"
}

data "aws_region" "near" {
  provider = aws.near
}

data "aws_region" "remote" {
  provider = aws.remote
}

resource "aws_key_pair" "near-keypair" {
  provider = aws.near
  key_name = "enak-ix-keypair"
  public_key = file("./keys/enak-ix-keypair.pub")
}

resource "aws_key_pair" "remote-keypair" {
  provider = aws.remote
  key_name = "enak-ix-keypair"
  public_key = file("./keys/enak-ix-keypair.pub")
}
