provider "aws" {
  alias = "near"
  region = "ap-northeast-2"
}

provider "aws" {
  alias = "remote"
  region = "ap-southeast-1"
}

resource "aws_key_pair" "keypair" {
  key_name = "enak-ix-keypair"
  public_key = file("./keys/enak-ix-keypair.pub")
}
