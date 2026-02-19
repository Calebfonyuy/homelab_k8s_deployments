# PostgreSQL Kubernetes Deployment

A PostgreSQL 17 deployment with persistent storage for homelab use.

## Overview

| Specification | Value |
|---------------|-------|
| Image | postgres:17 |
| Replicas | 1 |
| Service Type | NodePort |
| NodePort | 30083 |

## Files

| File | Description |
|------|-------------|
| deployment.yaml | Deployment with persistent volume |
| service.yaml | NodePort service for external access |
| secret.yaml | Kubernetes Secret for PostgreSQL credentials |
| pv.yaml | PersistentVolume for database storage |
| pvc.yaml | PersistentVolumeClaim |
| prepare_environment.yaml | Ansible playbook to create data directory |
| README.md | This documentation file |

## Storage

Database files are stored outside containers in a dedicated directory:

```
/home/data/postgres/
```

The PersistentVolume uses `persistentVolumeReclaimPolicy: Retain` to preserve data even if the PVC is deleted. This allows you to recover data or launch new projects against the existing database files.

## Prerequisites

- Kubernetes cluster with kubectl configured
- Ansible installed for running the prepare environment playbook
- Access to the control plane node

## Deployment

1. Prepare the environment (create data directory):
   ```bash
   ansible-playbook -i hosts.ini postgres/prepare_environment.yaml
   ```

2. Update the secrets in `secret.yaml` with a secure password:
   ```yaml
   stringData:
     POSTGRES_USER: homelab_admin
     POSTGRES_PASSWORD: your-secure-password
   ```

3. Apply the Kubernetes manifests:
   ```bash
   kubectl apply -f postgres/secret.yaml
   kubectl apply -f postgres/pv.yaml
   kubectl apply -f postgres/pvc.yaml
   kubectl apply -f postgres/service.yaml
   kubectl apply -f postgres/deployment.yaml
   ```

4. Verify the deployment:
   ```bash
   kubectl get pods -l app=postgres
   kubectl get pvc postgres-pvc
   kubectl get svc postgres
   ```

## Accessing PostgreSQL

### From within the cluster

```
postgres:5432
```

### From outside the cluster

```
<node-ip>:30083
```

### Connection string example

```
postgresql://homelab_admin:<password>@<node-ip>:30083/postgres
```

## Connecting from pgAdmin

If you have pgAdmin deployed, add a new server with:
- **Host**: `postgres` (from within cluster) or `<node-ip>` (external)
- **Port**: `5432` (internal) or `30083` (external)
- **Username**: `homelab_admin`
- **Password**: Value from `POSTGRES_PASSWORD` in secret.yaml

## Recovery

If you need to start fresh with existing data:

1. Ensure data directory exists at `/home/data/postgres`
2. Delete and recreate the deployment:
   ```bash
   kubectl delete deployment postgres
   kubectl apply -f postgres/deployment.yaml
   ```

The PersistentVolume with `Retain` policy ensures your data is preserved.

## Resource Limits

| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 250m | 1000m |
| Memory | 256Mi | 1Gi |

Adjust these values in `deployment.yaml` based on your workload requirements.

## Note on Replication

This deployment uses a single PostgreSQL instance. For high availability with automatic failover, consider using:
- [CloudNativePG Operator](https://cloudnative-pg.io/)
- [Crunchy Postgres Operator](https://www.crunchydata.com/products/crunchy-postgresql-for-kubernetes)
- [Zalando Postgres Operator](https://github.com/zalando/postgres-operator)
