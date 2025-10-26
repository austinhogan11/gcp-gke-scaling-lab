variable "project_id"     { type = string }
variable "region"         { type = string  default = "us-east1" }
variable "cluster_name"   { type = string  default = "srel-cluster" }
variable "network_name"   { type = string  default = "srel-vpc" }
variable "subnet_name"    { type = string  default = "srel-subnet" }
variable "node_machine_type" { type = string default = "e2-standard-4" }
variable "min_nodes"      { type = number  default = 1 }
variable "max_nodes"      { type = number  default = 3 }