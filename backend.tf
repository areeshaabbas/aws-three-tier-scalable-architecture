terraform {
  backend "s3" {
    bucket         = "areesha-scalable-webapp-tfstate"
    key            = "scalable-webapp/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "scalable-webapp-terraform-locks"
  }
}