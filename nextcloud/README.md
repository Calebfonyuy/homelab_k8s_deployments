# Nextcloud Deployment

Kubernetes deployment for Nextcloud with integrated PostgreSQL database.

## Project Structure

```
nextcloud/
├── deployment.yaml          # Nextcloud + PostgreSQL deployment
├── service.yaml             # NodePort service (port 30080)
├── secret.yaml              # Kubernetes secret template
└── prepare_environment.yaml # Ansible playbook for directory setup
```

## Data Directories

```
/home/data/nextcloud/
├── database/    # PostgreSQL data
└── files/       # Nextcloud files
```

## Configuration

- Self-contained deployment with PostgreSQL and Nextcloud containers
- PostgreSQL data stored at `/home/data/nextcloud/database`
- Nextcloud files stored at `/home/data/nextcloud/files`
- Exposed via NodePort on port `30080`
- All credentials pulled from Kubernetes Secret `nextcloud-secret`

## Deployment Instructions

### 1. Run the Ansible playbook

This creates the data directories on the host:

```bash
ansible-playbook -i hosts.ini nextcloud/prepare_environment.yaml
```

### 2. Configure and apply the secret

Edit `secret.yaml` with your credentials, then apply:

```bash
kubectl apply -f nextcloud/secret.yaml
```

### 3. Apply the Kubernetes manifests

```bash
kubectl apply -f nextcloud/deployment.yaml
kubectl apply -f nextcloud/service.yaml
```

### 4. Access Nextcloud

Open your browser and navigate to:

```
http://<node-ip>:30080
```

## Prerequisites

- Kubernetes cluster running
- Ansible installed (for the playbook)
