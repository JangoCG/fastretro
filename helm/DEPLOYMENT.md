# Kubernetes Deployment Guide

This guide explains how to deploy FastRetro to a Kubernetes cluster using Helm.

## Prerequisites

- Kubernetes cluster (1.24+)
- Helm 3.x installed
- kubectl configured to access your cluster
- **Gateway API** (recommended):
  - Gateway API CRDs installed (v1.0.0+)
  - Gateway controller (Istio, Cilium, Envoy Gateway, etc.)
- **OR Legacy Ingress**:
  - Ingress controller installed (e.g., nginx-ingress)
- (Optional) cert-manager for automatic TLS certificates

### Installing Gateway API

If you want to use the modern Gateway API approach, install the CRDs first:

```bash
# Install Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

# Then install your preferred Gateway controller, for example:

# Istio
istioctl install --set profile=minimal -y

# Or Cilium
helm install cilium cilium/cilium --version 1.14.0 \
  --namespace kube-system \
  --set kubeProxyReplacement=strict \
  --set gatewayAPI.enabled=true

# Or Envoy Gateway
helm install eg oci://docker.io/envoyproxy/gateway-helm \
  --version v0.6.0 \
  -n envoy-gateway-system \
  --create-namespace
```

## Quick Start

### 1. Add the Helm Repository

```bash
helm repo add fastretro https://jack-in-the-box.github.io/fastretro/
helm repo update
```

### 2. Generate Required Secrets

Before installation, you need to generate the application key and Reverb secrets:

```bash
# Generate Laravel app key (run this in your local Laravel installation or use Docker)
docker run --rm ghcr.io/jack-in-the-box/fastretro:latest php artisan key:generate --show

# Generate Reverb credentials (you can use any random strings)
REVERB_APP_ID=$(openssl rand -hex 16)
REVERB_APP_KEY=$(openssl rand -hex 16)
REVERB_APP_SECRET=$(openssl rand -hex 32)

echo "APP_KEY: base64:..."
echo "REVERB_APP_ID: $REVERB_APP_ID"
echo "REVERB_APP_KEY: $REVERB_APP_KEY"
echo "REVERB_APP_SECRET: $REVERB_APP_SECRET"
```

### 3. Create a values file

Create a `my-values.yaml` file with your configuration:

```yaml
app:
  name: FastRetro
  url: https://fastretro.example.com
  key: "base64:YOUR_GENERATED_APP_KEY_HERE"

reverb:
  appId: "YOUR_REVERB_APP_ID"
  appKey: "YOUR_REVERB_APP_KEY"
  appSecret: "YOUR_REVERB_APP_SECRET"

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: fastretro.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: fastretro-tls
      hosts:
        - fastretro.example.com

persistence:
  enabled: true
  size: 5Gi
  # storageClass: "standard"
```

### 4. Install the Chart

#### Option A: Using Gateway API (Recommended)

```bash
helm install my-fastretro fastretro/fastretro -f my-values.yaml
```

Or install with inline values using Gateway API:

```bash
helm install my-fastretro fastretro/fastretro \
  --set app.url=https://fastretro.example.com \
  --set app.key="base64:YOUR_KEY" \
  --set reverb.appId="YOUR_APP_ID" \
  --set reverb.appKey="YOUR_APP_KEY" \
  --set reverb.appSecret="YOUR_APP_SECRET" \
  --set gateway.enabled=true \
  --set gateway.gatewayName="my-gateway" \
  --set gateway.hostnames[0]="fastretro.example.com"
```

#### Option B: Using Legacy Ingress

```bash
helm install my-fastretro fastretro/fastretro \
  --set app.url=https://fastretro.example.com \
  --set app.key="base64:YOUR_KEY" \
  --set reverb.appId="YOUR_APP_ID" \
  --set reverb.appKey="YOUR_APP_KEY" \
  --set reverb.appSecret="YOUR_APP_SECRET" \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=fastretro.example.com
```

## Configuration

### Required Values

| Parameter | Description | Example |
|-----------|-------------|---------|
| `app.key` | Laravel application key | `base64:...` |
| `app.url` | Application URL | `https://fastretro.example.com` |
| `reverb.appId` | Reverb application ID | Random hex string |
| `reverb.appKey` | Reverb application key (public) | Random hex string |
| `reverb.appSecret` | Reverb application secret | Random hex string |

### Common Customizations

#### Enable Gateway API with TLS (Recommended)

Using an existing Gateway:
```yaml
gateway:
  enabled: true
  gatewayName: "my-gateway"
  namespace: "gateway-system"
  hostnames:
    - fastretro.example.com
```

Creating a new Gateway with TLS:
```yaml
gateway:
  enabled: true
  createGateway: true
  gatewayClassName: "istio"  # or "cilium", "envoy-gateway", etc.
  gatewayName: "fastretro-gateway"
  hostnames:
    - fastretro.example.com
  tls:
    enabled: true
    certificateRef: fastretro-tls
  gatewayAnnotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
```

#### Enable Legacy Ingress with TLS

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: fastretro.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: fastretro-tls
      hosts:
        - fastretro.example.com
```

#### Adjust Resources

```yaml
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
```

#### Enable Autoscaling

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

#### Configure Persistent Storage

```yaml
persistence:
  enabled: true
  storageClass: "fast-ssd"
  size: 10Gi
```

## Upgrading

```bash
helm repo update
helm upgrade my-fastretro fastretro/fastretro -f my-values.yaml
```

## Uninstalling

```bash
helm uninstall my-fastretro
```

## Verifying the Installation

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=fastretro
```

### Check Services

```bash
kubectl get svc -l app.kubernetes.io/name=fastretro
```

### Check Ingress

```bash
kubectl get ingress
```

### View Logs

```bash
# Application logs
kubectl logs -l app.kubernetes.io/name=fastretro -f

# Migration job logs
kubectl logs job/my-fastretro-migrate
```

## Troubleshooting

### Pods Not Starting

Check pod events:
```bash
kubectl describe pod <pod-name>
```

Check application logs:
```bash
kubectl logs <pod-name>
```

### Database Issues

Check if the SQLite database is properly initialized:
```bash
kubectl exec -it <pod-name> -- ls -la /var/www/html/storage/database/
```

### WebSocket Connection Issues

1. Verify the Reverb service is running:
```bash
kubectl get svc my-fastretro-reverb
```

2. Check ingress configuration for WebSocket support:
```bash
kubectl get ingress my-fastretro-reverb -o yaml
```

3. Ensure your ingress controller supports WebSocket connections

### Persistent Volume Issues

Check PVC status:
```bash
kubectl get pvc
kubectl describe pvc <pvc-name>
```

## Advanced Configuration

### Using MySQL/PostgreSQL Instead of SQLite

Update your values:

```yaml
database:
  connection: mysql
  host: mysql.default.svc.cluster.local
  port: 3306
  database: fastretro
  username: fastretro
  password: "your-password"

# Disable SQLite-specific volume mount
persistence:
  enabled: false
```

Then add database credentials to the ConfigMap and Secret templates.

### Running Queue Workers

Add a separate deployment for queue workers:

```yaml
queueWorker:
  enabled: true
  replicaCount: 2
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
```

### Custom Environment Variables

Add custom environment variables via ConfigMap:

```yaml
extraEnv:
  - name: CUSTOM_VAR
    value: "custom-value"
```

## Security Considerations

1. **Always use TLS/HTTPS** in production
2. **Store secrets securely** using Kubernetes Secrets or external secret managers
3. **Regularly update** the Docker image and Helm chart
4. **Configure network policies** to restrict traffic
5. **Enable pod security policies** or pod security standards
6. **Use resource limits** to prevent resource exhaustion

## Performance Tuning

### For High Traffic

```yaml
replicaCount: 5

resources:
  limits:
    cpu: 2000m
    memory: 2Gi
  requests:
    cpu: 1000m
    memory: 1Gi

autoscaling:
  enabled: true
  minReplicas: 5
  maxReplicas: 20
  targetCPUUtilizationPercentage: 70

# Consider using Redis for cache and session
cache:
  driver: redis
session:
  driver: redis
```

## Monitoring

### Prometheus Metrics

Add Prometheus annotations to enable scraping:

```yaml
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  prometheus.io/path: "/metrics"
```

## Support

For issues and questions:
- GitHub Issues: https://github.com/jack-in-the-box/fastretro/issues
- Documentation: https://github.com/jack-in-the-box/fastretro
