provider "aws" {
  alias = "seoul"
  access_key = "AKIAYTIRB5LWYZJ4TC65"
  secret_key = "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"
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
