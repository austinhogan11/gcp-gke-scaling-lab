terraform {
  backend "gcs" {
    bucket  = "sr-eng-tfstate"
    prefix  = "env/prod"
  }
}