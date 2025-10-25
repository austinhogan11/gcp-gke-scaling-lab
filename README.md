# GKE Infrastructure & Auto-Scaling Lab

## Steps

### Step 1 Set up & Configure GCP
1 Account/Project Config
account = <account>
project = sr-eng-prep
region = us-east1
zone = us-east1-b

2 Enable APIs
gcloud services enable \
  container.googleapis.com \
  compute.googleapis.com \
  iam.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com

3 Set & Verify IAM Permissions
gcloud auth list
gcloud config set account <account>

4 Verify Billing
gcloud beta billing accounts list
gcloud beta billing projects describe sr-eng-prep

# Terraform & GCP/GKE Infrastructure Setup
- Single source of truth for the project infra
- Managing with TF
    - Project Services/APIs
    - Networking
        - VPC
        - Subnet
    - GKE
        - Standard Cluster
            - us-east-1
            - workload Identity enables
            - Logging/Monitoring
            - Remove default node poo
            - node pool with 
                - auto scaling 1:3
                - auto-repair
                - auto-upgrade
    - Artifact Registry (Container Images)
        - regional docker repo
    - IAM / Service Accounts
        - workload SA (minimum roles)
            - roles/artifactregistry.reader
	        - roles/storage.objectViewer (for future GCS reads)
            - roles/pubsub.subscriber if we play with Pub/Sub
        - Workload Identity binding so a KSA (e.g., default/app-ksa) can impersonate app-gsa
    - Other
        - Pub/Sub topic + subscription for event driven workers
        - GCS bucket for LLM model or artifact dumps
        - Kubernetes RBAC - role binding for user
    Structure
        terraform/
        ├── providers.tf
        ├── variables.tf
        ├── network.tf
        ├── gke.tf
        ├── artifact_registry.tf
        ├── iam.tf
        ├── services.tf
        ├── outputs.tf
        └── terraform.tfvars.example