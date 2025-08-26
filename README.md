# GKE on Google Cloud — Terraform

This repo provisions a **VPC-native GKE cluster** with a custom VPC, regional subnet, secondary IP ranges for Pods/Services, least-privileged node service accounts, and a managed node pool with auto-repair/upgrade. Remote state is stored in a **GCS bucket** for team collaboration.

---

## What will be created:

- **GCP APIs enabled up-front** (`compute`, `container`, `iam`, `cloudresourcemanager`, `serviceusage`, etc.)
- **Custom VPC** + **regional subnet** with **Private Google Access**
- **Secondary ranges** for **Pods** and **Services** (VPC-native GKE)
- **Firewall**: targeted SSH rule using network tags (not 0.0.0.0/0)
- **GKE cluster** (release channel = `REGULAR`) with Cloud Logging/Monitoring
- Node **labels** + **network tags**
- Attached **least-privileged Service Account**
- Legacy metadata endpoints disabled
- Useful **outputs** (cluster name, endpoint, CA, network artifacts)

---

## 🧰 Prerequisites

- Terraform version needs to be stated.: **v1.5+**
- Google provider version must be stated :  **v5+**
- A GCS bucket for remote state
- Project has sufficient **quotas** (CPU, IPs)

---

## Steps:

1. **Authenticate to Google**
2. Initialize Terraform
  - terraform init
  - terraform validate
  - terraform plan & apply

3.  Get cluster credentials through outputs.

4. Access Cluster.

**🔒 Security posture for Simple GKE cluster creation**

-  Least privilege node SA (roles/logging.logWriter, roles/monitoring.metricWriter)

-  Private Google Access on the subnet

-  Disable legacy metadata endpoints

-  Targeted firewall via network tags

-  Future hardening: Workload Identity, Shielded Nodes, Network Policies

♻️ Teardown
-  terraform destroy

**Summary**

-  This setup is a reproducible GKE baseline:

      -  Remote state in GCS.
      -  APIs enabled up front
      -  VPC-native networking with secondary ranges
      -  Least-privileged node identity
      -  Managed node pool with auto-repair/upgrade
