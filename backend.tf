terraform {
  backend "s3" {
    bucket = "backendofterraformprojectforinfra"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}
