variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east1"
}

variable "zone" {
  type    = string
  default = "us-east1-b"
}

variable "cluster_name" {
  type    = string
  default = "srel-cluster"
}

variable "network_name" {
  type    = string
  default = "srel-vpc"
}

variable "subnet_name" {
  type    = string
  default = "srel-subnet"
}

variable "node_machine_type" {
  type    = string
  default = "e2-standard-4"
}

variable "min_nodes" {
  type    = number
  default = 1
}

variable "max_nodes" {
  type    = number
  default = 3
}

variable "artifact_repo_id" {
  type    = string
  default = "sr-eng-docker"
}