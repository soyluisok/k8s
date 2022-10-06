terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "myk8s-tfstate"
    key            = "state.tfstate"
    dynamodb_table = "myk8s-table"
    encrypt        = true
  }
}
