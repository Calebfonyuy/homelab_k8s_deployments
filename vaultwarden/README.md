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
| `pv.yaml` | PersistentVolume using hostPath at `/home/data/vaultwarden` |
| `pvc.yaml` | PersistentVolumeClaim bound to the PV |

## Prerequisites

1. Kubernetes cluster
2. The hostPath directory `/home/data/vaultwarden` will be created automatically on the node

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

Apply in order (PV and PVC first, then secret, deployment, and service):

```bash
kubectl apply -f vaultwarden/pv.yaml
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
kubectl get pv vaultwarden-pv
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

The PV uses a `hostPath` volume at `/home/data/vaultwarden` on the node. The PVC uses `ReadWriteOnce` access mode, meaning it can only be mounted by a single node. This is appropriate for Vaultwarden since it uses SQLite and should run as a single replica.

The `persistentVolumeReclaimPolicy` is set to `Retain`, so data will persist even if the PVC is deleted.

## Security Recommendations

1. Use HTTPS (configure an Ingress with TLS or reverse proxy)
2. Set a strong admin token
3. Disable signups after creating your accounts (`SIGNUPS_ALLOWED=false`)
4. Configure email for password reset functionality
5. Regular backups of the PVC data
