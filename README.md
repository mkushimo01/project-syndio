# GKE Baseline on Google Cloud — Terraform

This repo provisions a **VPC-native GKE cluster** with a custom VPC, regional subnet, secondary IP ranges for Pods/Services, least-privileged node service accounts, and a managed node pool with auto-repair/upgrade. Remote state is stored in a **GCS bucket** for team collaboration.

---

## 📌 What this delivers

- **GCP APIs enabled up-front** (`compute`, `container`, `iam`, `cloudresourcemanager`, `serviceusage`, etc.)
- **Custom VPC** + **regional subnet** with **Private Google Access**
- **Secondary ranges** for **Pods** and **Services** (VPC-native GKE)
- **Firewall**: targeted SSH rule using network tags (not 0.0.0.0/0)
- **GKE cluster** (release channel = `REGULAR`) with Cloud Logging/Monitoring
- Default node pool removed; **managed node pool** created with:
  - `auto_upgrade` + `auto_repair`
  - Node **labels** + **network tags**
  - Attached **least-privileged Service Account**
  - Legacy metadata endpoints disabled
- Useful **outputs** (cluster name, endpoint, CA, network artifacts)

---

## 🧰 Prerequisites

- Terraform **v1.5+**
- Google provider **v5+**
- A GCS bucket for remote state
- `gcloud` CLI authenticated to the target project
- Project has sufficient **quotas** (CPU, IPs)

---

## 🚀 Usage

1. **Authenticate to Google**
   ```bash
   gcloud auth application-default login
   gcloud config set project <YOUR_PROJECT_ID>
Initialize Terraform

terraform init
terraform validate


Plan & Apply

terraform plan -out=tfplan
terraform apply tfplan


Get cluster credentials

gcloud container clusters get-credentials "$(terraform output -raw cluster_name)" \
  --region "$(terraform output -raw region)" \
  --project "$(terraform output -raw project_id)"

kubectl get nodes

🔒 Security posture

Least privilege node SA (roles/logging.logWriter, roles/monitoring.metricWriter)

Private Google Access on the subnet

Disable legacy metadata endpoints

Targeted firewall via network tags

Future hardening: Workload Identity, Shielded Nodes, Network Policies

♻️ Teardown
terraform destroy

✅ Summary

This setup is a reproducible GKE baseline:

Remote state in GCS

APIs enabled up front

VPC-native networking with secondary ranges

Least-privileged node identity

Managed node pool with auto-repair/upgrade
