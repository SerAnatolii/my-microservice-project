terraform {
  backend "s3" {
    bucket         = "lesson-5-terraform-state-bucket-anatolii"  
    key            = "lesson-7/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}