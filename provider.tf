provider "aws" {
  alias = "seoul"
  region = "ap-northeast-2"
}

provider "aws" {
  alias = "singapore"
  region = "ap-southeast-1"
}

resource "aws_key_pair" "keypair" {
    provider = aws.seoul
    key_name = "enak-ix-keypair"
    public_key = file("./keys/enak-ix-keypair.pub")
}
