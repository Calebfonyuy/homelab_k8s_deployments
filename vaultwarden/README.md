# Vaultwarden Kubernetes Deployment

This project deploys Vaultwarden (a self-hosted Bitwarden-compatible password manager) on Kubernetes.

## Overview

- **Image**: `vaultwarden/server:latest`
- **Replicas**: 1 (single instance due to SQLite database)
- **Service Type**: NodePort (port 30082)
- **Storage**: PersistentVolumeClaim (1Gi)

## Files

| File | Description |
|------|-------------|
| `deployment.yaml` | Deployment configuration |
| `service.yaml` | NodePort service exposing Vaultwarden on port 30082 |
| `secret.yaml` | Admin panel token |
| `pvc.yaml` | PersistentVolumeClaim for data storage |

## Prerequisites

1. Kubernetes cluster with a StorageClass configured (for dynamic PV provisioning)
2. Or a manually created PersistentVolume matching the PVC

## Deployment Steps

### 1. Update the admin token

Edit `secret.yaml` and set a secure admin token:

```yaml
stringData:
  admin-token: your-secure-random-token
```

Generate a secure token:

```bash
openssl rand -base64 48
```

### 2. Deploy to Kubernetes

Apply in order (PVC first, then secret, deployment, and service):

```bash
kubectl apply -f vaultwarden/pvc.yaml
kubectl apply -f vaultwarden/secret.yaml
kubectl apply -f vaultwarden/deployment.yaml
kubectl apply -f vaultwarden/service.yaml
```

Or all at once:

```bash
kubectl apply -f vaultwarden/
```

### 3. Verify deployment

```bash
kubectl get pvc vaultwarden-pvc
kubectl get pods -l app=vaultwarden
kubectl get svc vaultwarden
```

## Accessing Vaultwarden

### Web Vault

Access the web interface at:

```
http://<node-ip>:30082
```

### Admin Panel

Access the admin panel at:

```
http://<node-ip>:30082/admin
```

Use the admin token from `secret.yaml` to log in.

## Configuration Options

Common environment variables (add to deployment.yaml):

| Variable | Description | Default |
|----------|-------------|---------|
| `SIGNUPS_ALLOWED` | Allow new user registrations | `true` |
| `WEBSOCKET_ENABLED` | Enable WebSocket notifications | `true` |
| `ADMIN_TOKEN` | Token for admin panel access | Required |
| `DOMAIN` | Full URL where Vaultwarden is hosted | - |
| `SMTP_HOST` | SMTP server for email | - |

## Storage

The PVC uses `ReadWriteOnce` access mode, meaning it can only be mounted by a single node. This is appropriate for Vaultwarden since it uses SQLite and should run as a single replica.

To use a specific StorageClass, add to `pvc.yaml`:

```yaml
spec:
  storageClassName: your-storage-class
```

## Security Recommendations

1. Use HTTPS (configure an Ingress with TLS or reverse proxy)
2. Set a strong admin token
3. Disable signups after creating your accounts (`SIGNUPS_ALLOWED=false`)
4. Configure email for password reset functionality
5. Regular backups of the PVC data
