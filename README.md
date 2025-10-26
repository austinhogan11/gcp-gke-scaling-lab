# GKE Infrastructure & Auto-Scaling Lab

## Steps

### 1 Set up & Configure GCP
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

## 2 Terraform & GCP/GKE Infrastructure Setup
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

- Create infra with TF
    cd terraform
    terraform init
    terraform plan -var="project_id=sr-eng-prep"
    terraform apply -auto-approve -var="project_id=sr-eng-prep"
    terraform output get_credentials_cmd
    # run the printed command, then:
    kubectl get nodes

## Deploy Nginx on K8s, simulate load, observe scaling, clean up
1. serviceaccount.yaml
- Create a K8s Service account for the pods -> app-ksa
- Annotate Google SA (app-gsa), links to app-ksa with workload identity
    - This allows pods to access GCP services without JSON keys

2. Deployment.yaml
- Deploys nginx as a Deployment -> demo-nginx
    - starts with 1 replica
    - health probes
    - sets resource requests/limits for HPA to have a target
- label the app (demo-nginx) for other resources to find pods

3. service.yaml
- exposes deployment with a service -> demo-nginx-svc
- type -> LoadBalancer
    - creates a Google LB with External IP
    - traffic to ext IP is load balanced on the pods

4. hpa.yaml
- configs HPA (horizontal pod autoscaler) for deployment
    - target = 50% cpu util
    - min:max -> 1:5 replicas
    - When avg cpu >50% scales up; below, drops down
5. loadgen-fortio.yaml
- Load test
- simualtes load to scale cluster up

Deployment & OBservation Steps
1. Deploy k8s files / app
kubectl apply -f k8s/serviceaccount.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml

2. Get the external IP 
kubectl get svc demo-nginx-svc -w
export SVC_IP=$(kubectl get svc demo-nginx-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo $SVC_IP

3. generate load 
kubectl apply -f k8s/loadgen-fortio.yaml
kubectl get pods -l app=loadgen

4. observe autoscaling
#### Watch HPA decisions (TARGETS and REPLICAS will change)
kubectl get hpa demo-nginx-hpa -w

#### Watch the deployment scale pods
kubectl get deploy demo-nginx -w

#### Optional: see live CPU if metrics are ready
kubectl top pods --use-protocol-buffers

Result
- Targets CPU util increases above 50%
- Replicas climb up to 5

5. stop the load
kubectl delete -f k8s/loadgen-fortio.yaml

