# pgAdmin Kubernetes Deployment

This project deploys pgAdmin 4 on Kubernetes with auto-scaling capabilities.

## Overview

- **Image**: `dpage/pgadmin4:latest`
- **Replicas**: Minimum 2, Maximum 4 (managed by HorizontalPodAutoscaler)
- **Service Type**: NodePort (port 30081)
- **Scaling Metrics**: CPU (70% threshold) and Memory (80% threshold)

## Files

| File | Description |
|------|-------------|
| `deployment.yaml` | Deployment and HorizontalPodAutoscaler configuration |
| `service.yaml` | NodePort service exposing pgAdmin on port 30081 |
| `secret.yaml` | Credentials for pgAdmin admin user |
| `prepare_environment.yaml` | Ansible playbook to prepare host directories |

## Prerequisites

1. Kubernetes cluster with metrics-server installed (required for HPA)
2. Ansible installed on the control machine
3. SSH access to the control plane node

## Deployment Steps

### 1. Prepare the environment

Run the Ansible playbook to create the required directories on the host:

```bash
ansible-playbook -i hosts.ini pgadmin/prepare_environment.yaml
```

### 2. Update credentials

Edit `secret.yaml` and update the default credentials:

```yaml
stringData:
  pgadmin-default-email: your-email@example.com
  pgadmin-default-password: your-secure-password
```

### 3. Deploy to Kubernetes

```bash
kubectl apply -f pgadmin/secret.yaml
kubectl apply -f pgadmin/deployment.yaml
kubectl apply -f pgadmin/service.yaml
```

### 4. Verify deployment

```bash
kubectl get pods -l app=pgadmin
kubectl get hpa pgadmin-hpa
kubectl get svc pgadmin
```

## Accessing pgAdmin

Once deployed, access pgAdmin at:

```
http://<node-ip>:30081
```

Login with the credentials configured in `secret.yaml`.

## Scaling Behavior

The HorizontalPodAutoscaler maintains between 2-4 replicas based on:
- CPU utilization: scales up when average exceeds 70%
- Memory utilization: scales up when average exceeds 80%

To check current scaling status:

```bash
kubectl get hpa pgadmin-hpa
kubectl describe hpa pgadmin-hpa
```

## Connecting to PostgreSQL Databases

After logging in to pgAdmin, you can add PostgreSQL servers:

1. Right-click "Servers" > "Create" > "Server"
2. Enter connection details for your PostgreSQL database
3. For databases running in the same cluster, use the Kubernetes service name as the hostname
