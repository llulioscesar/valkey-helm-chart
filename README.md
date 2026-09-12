# Valkey Helm Chart

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/valkey-redis)](https://artifacthub.io/packages/helm/valkey-redis/valkey)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Helm](https://img.shields.io/badge/Helm-3.x-blue)](https://helm.sh)
[![Auto-Update](https://img.shields.io/badge/Auto--Update-Weekly-green)](https://github.com/start-codex/valkey-helm-chart/actions/workflows/update-valkey-version.yml)
[![Chainguard](https://img.shields.io/badge/Images-Chainguard%20%7C%20Zero%20CVE-brightgreen)](https://www.chainguard.dev/)

<p align="center">
  <img src="https://valkey.io/img/valkey-logo-og.png" alt="Valkey Logo" width="300">
</p>

Helm chart for deploying [Valkey](https://valkey.io/) on Kubernetes. Valkey is a high-performance, open-source data structure server compatible with Redis.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Image Versioning Strategy](#image-versioning-strategy)
- [Quick Start](#quick-start)
- [Architectures](#architectures)
- [Configuration](#configuration)
- [Examples](#examples)
- [Connecting to Valkey](#connecting-to-valkey)
- [Upgrades](#upgrades)
- [Monitoring](#monitoring)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Uninstallation](#uninstallation)
- [Development](#development)
- [Contributing](#contributing)
- [Links](#links)
- [License](#license)

## Features

| Feature | Description |
|---------|-------------|
| **Standalone Mode** | Simple single-instance deployment |
| **Sentinel Mode** | High availability with automatic failover |
| **Authentication** | Support for password and existing secrets |
| **Persistence** | Configurable persistent volumes |
| **Metrics** | Built-in Prometheus exporter |
| **Security** | SecurityContext, NetworkPolicies, RBAC |
| **Quiet Upgrades** | A chart version bump changes no immutable StatefulSet field and no pod template, so it neither fails nor restarts pods |
| **TLS** | Support for encrypted connections |

## Requirements

| Component | Version |
|-----------|---------|
| Kubernetes | >= 1.23 |
| Helm | >= 3.8 |

## Image Versioning Strategy

This chart uses **Chainguard's zero-CVE Valkey images** for enhanced security.

### Why `latest` tag?

- **Free tier limitation**: Chainguard's free tier only provides the `latest` tag
- **Automatic updates**: Using `latest` ensures you always get the most recent security patches
- **Zero CVEs**: Chainguard images are rebuilt continuously to maintain zero known vulnerabilities

### Version tracking

- **appVersion in Chart.yaml**: Reflects the current Valkey version available in `cgr.dev/chainguard/valkey:latest`
- **Automated updates**: A GitHub Action checks weekly for version updates and creates PRs automatically
- **Transparency**: Every version change is tracked via pull requests and changelog entries

### For production use

If you require **version pinning** for production:

```yaml
# Override with a specific version (requires Chainguard Pro or alternative registry)
image:
  registry: docker.io        # The default is cgr.dev, so override it too
  repository: valkey/valkey  # Official Valkey images
  tag: "9.1.2"               # Specific version tag
```

> **Note**: Using `latest` provides continuous security updates but means deployments may pull different versions over time. For strict reproducibility, consider using image digests or switching to a registry that provides versioned tags.

## Quick Start

```bash
# Add the repository
helm repo add valkey https://start-codex.github.io/valkey-helm-chart
helm repo update

# Install with default values
helm install my-valkey valkey/valkey

# Install with authentication
helm install my-valkey valkey/valkey \
  --set auth.enabled=true \
  --set auth.password="your-secure-password"
```

## Architectures

### Standalone (Default)

Simple deployment with a single Valkey instance. Ideal for development and workloads that don't require high availability.

```
+------------------+
|     Valkey       |
|   (standalone)   |
+------------------+
        |
+------------------+
|       PVC        |
+------------------+
```

```bash
helm install my-valkey valkey/valkey
```

### Sentinel (High Availability)

Architecture with master, replicas, and sentinels for automatic failover. Recommended for production.

```
+------------------+     +------------------+     +------------------+
|     Sentinel     |     |     Sentinel     |     |     Sentinel     |
+------------------+     +------------------+     +------------------+
         |                       |                        |
         +-------------+---------+------------------------+
                       |
         +-------------+-------------+
         |             |             |
+--------v---+  +------v-----+  +----v-------+
|   Master   |  |  Replica   |  |  Replica   |
+------------+  +------------+  +------------+
      |              |               |
+-----v----+  +------v-----+  +-----v------+
|   PVC    |  |    PVC     |  |    PVC     |
+----------+  +------------+  +------------+
```

```bash
helm install my-valkey valkey/valkey \
  --set architecture=sentinel \
  --set sentinel.replicaCount=3 \
  --set replica.replicaCount=2
```

## Configuration

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `architecture` | Deployment mode: `standalone` or `sentinel` | `standalone` |
| `global.imageRegistry` | Global registry for all images | `""` |
| `global.storageClass` | Global StorageClass | `""` |
| `clusterDomain` | Kubernetes cluster domain | `cluster.local` |

### Image

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.registry` | Image registry | `cgr.dev` |
| `image.repository` | Image repository | `chainguard/valkey` |
| `image.tag` | Image tag (see [Image Versioning Strategy](#image-versioning-strategy)) | `latest` |
| `image.pullPolicy` | Pull policy | `IfNotPresent` |

### Authentication

| Parameter | Description | Default |
|-----------|-------------|---------|
| `auth.enabled` | Enable authentication | `false` |
| `auth.password` | Password (not recommended for production) | `""` |
| `auth.existingSecret` | Name of existing Secret | `""` |
| `auth.existingSecretPasswordKey` | Password key in Secret | `password` |

### Standalone

| Parameter | Description | Default |
|-----------|-------------|---------|
| `standalone.replicaCount` | Number of replicas | `1` |
| `standalone.persistence.enabled` | Enable persistence | `true` |
| `standalone.persistence.size` | Volume size | `8Gi` |
| `standalone.persistence.storageClass` | StorageClass | `""` |
| `standalone.service.type` | Service type | `ClusterIP` |
| `standalone.service.port` | Service port | `6379` |
| `standalone.resources.requests.memory` | Memory request | `128Mi` |
| `standalone.resources.requests.cpu` | CPU request | `100m` |
| `standalone.resources.limits.memory` | Memory limit | `256Mi` |

### Sentinel

| Parameter | Description | Default |
|-----------|-------------|---------|
| `sentinel.replicaCount` | Number of sentinels | `3` |
| `sentinel.quorum` | Quorum for failover | `2` |
| `sentinel.downAfterMilliseconds` | Time to detect failure | `30000` |
| `sentinel.failoverTimeout` | Failover timeout | `30000` |
| `sentinel.masterSet` | Monitored master set name | `mymaster` |
| `master.replicaCount` | Number of masters | `1` |
| `replica.replicaCount` | Number of replicas | `2` |

### Metrics

| Parameter | Description | Default |
|-----------|-------------|---------|
| `metrics.enabled` | Enable Prometheus exporter | `false` |
| `metrics.image.repository` | Exporter image | `oliver006/redis_exporter` |
| `metrics.image.tag` | Exporter tag | `v1.91.1` |
| `metrics.serviceMonitor.enabled` | Create ServiceMonitor | `false` |
| `metrics.podMonitor.enabled` | Create PodMonitor | `false` |

### Security

| Parameter | Description | Default |
|-----------|-------------|---------|
| `podSecurityContext.fsGroup` | Filesystem group | `65532` |
| `podSecurityContext.runAsUser` | Container user | `65532` |
| `podSecurityContext.runAsGroup` | Container group | `65532` |
| `securityContext.runAsNonRoot` | Run as non-root | `true` |
| `securityContext.readOnlyRootFilesystem` | Read-only filesystem | `true` |
| `networkPolicy.enabled` | Enable NetworkPolicy | `false` |

## Examples

### Local Development

```yaml
# values-dev.yaml
architecture: standalone
auth:
  enabled: false
standalone:
  persistence:
    enabled: false
  resources:
    requests:
      memory: 64Mi
      cpu: 50m
    limits:
      memory: 128Mi
```

```bash
helm install valkey-dev valkey/valkey -f values-dev.yaml
```

### Production with Authentication

```yaml
# values-prod.yaml
architecture: standalone
auth:
  enabled: true
  existingSecret: valkey-secret
  existingSecretPasswordKey: password
standalone:
  persistence:
    enabled: true
    storageClass: fast-ssd
    size: 50Gi
  resources:
    requests:
      memory: 1Gi
      cpu: 500m
    limits:
      memory: 2Gi
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
```

```bash
# Create the secret first
kubectl create secret generic valkey-secret \
  --from-literal=password="your-super-secure-password"

# Install
helm install valkey-prod valkey/valkey -f values-prod.yaml
```

### High Availability with Sentinel

```yaml
# values-ha.yaml
architecture: sentinel
auth:
  enabled: true
  password: "ha-password"

sentinel:
  replicaCount: 3
  quorum: 2
  resources:
    requests:
      memory: 128Mi
      cpu: 100m

master:
  persistence:
    enabled: true
    size: 20Gi
  resources:
    requests:
      memory: 512Mi
      cpu: 250m
    limits:
      memory: 1Gi

replica:
  replicaCount: 2
  persistence:
    enabled: true
    size: 20Gi
  resources:
    requests:
      memory: 512Mi
      cpu: 250m
    limits:
      memory: 1Gi

metrics:
  enabled: true
  serviceMonitor:
    enabled: true
```

```bash
helm install valkey-ha valkey/valkey -f values-ha.yaml
```

### With Network Policies

```yaml
# values-secure.yaml
architecture: standalone
auth:
  enabled: true
  existingSecret: valkey-secret

networkPolicy:
  enabled: true
  allowExternal: false
  ingressNSMatchLabels:
    app: my-app
```

## Connecting to Valkey

### From Inside the Cluster

```bash
# Temporary pod for testing
kubectl run valkey-client --rm -it \
  --image=valkey/valkey:9.1.2 \
  -- valkey-cli -h my-valkey

# With authentication
kubectl run valkey-client --rm -it \
  --image=valkey/valkey:9.1.2 \
  -- valkey-cli -h my-valkey -a "your-password"
```

### Port-forward for Local Access

```bash
kubectl port-forward svc/my-valkey 6379:6379

# In another terminal
valkey-cli -h localhost -p 6379
```

### Sentinel - Get Current Master

```bash
kubectl run valkey-client --rm -it \
  --image=valkey/valkey:9.1.2 \
  -- valkey-cli -h my-valkey-sentinel -p 26379

# Useful sentinel commands
> SENTINEL masters
> SENTINEL get-master-addr-by-name mymaster
> SENTINEL replicas mymaster
```

## Upgrades

An upgrade is a plain Helm rolling update, and from 0.3.2 on a version bump alone
**does not restart any pod**.

Two things make that true. No StatefulSet field that Kubernetes refuses to update
in place (`serviceName`, selector, `volumeClaimTemplates`, `podManagementPolicy`)
changes between releases, so nothing has to be deleted and recreated. And no pod
template changes either: the pod templates and both ConfigMaps use only the stable
selector labels, so the `checksum/configmap` and `checksum/health` annotations stay
put unless the configuration itself changes. Pods restart when the image or the
configuration changes, and not otherwise.

> **Upgrading from 0.2.10 or earlier: one manual step**
>
> Up to 0.2.10 the `volumeClaimTemplates` carried the `helm.sh/chart` and
> `app.kubernetes.io/version` labels. Those change with every release, and
> `volumeClaimTemplates` is immutable, so every upgrade failed with
> `Forbidden: updates to statefulset spec` unless the StatefulSets were deleted
> first. From 0.3.0 they use the stable selector labels instead.
>
> Moving onto 0.3.0 is therefore the last upgrade that changes an immutable
> field. Run it once with `--set preUpgradeHook.enabled=true`, or delete the
> StatefulSets yourself with `--cascade=orphan`. **In sentinel mode, do not
> delete the sentinel StatefulSet**: it has no `volumeClaimTemplates`, it never
> needed recreating, and restarting the sentinels together with the data pods is
> how an upgrade ends up with no master at all. Delete the master and replica
> StatefulSets one at a time, waiting for each to come back.

> **Upgrading from 0.3.0: one last restart**
>
> 0.3.1 removes the chart version from the pod templates and the ConfigMaps, so
> the checksum annotations settle for the last time and every pod restarts once.
> It is a plain rolling update — no immutable field changes, nothing to delete.
> From 0.3.2 on, a version bump restarts nothing.

### The pre-upgrade hook

Disabled by default (`preUpgradeHook.enabled`). It deletes the StatefulSets with
`--cascade=orphan` — pods and PVCs survive — so Helm can recreate them. Enable it
only for a release whose notes say an immutable field changed. While enabled, the
upgrade also depends on pulling the hook image, and stays in `pending-upgrade` if
that pull fails.

### Upgrading the Chart

```bash
# Update repository
helm repo update

# View available versions
helm search repo valkey/valkey --versions

# Upgrade to latest version
helm upgrade my-valkey valkey/valkey

# Upgrade with new values
helm upgrade my-valkey valkey/valkey -f new-values.yaml

# Pin the Valkey image to a specific version
helm upgrade my-valkey valkey/valkey \
  --set image.registry=docker.io \
  --set image.repository=valkey/valkey \
  --set image.tag=9.1.2
```

### Hook Configuration

```yaml
preUpgradeHook:
  enabled: false
  image:
    registry: cgr.dev
    repository: chainguard/kubectl
    tag: "latest"
  resources:
    limits:
      memory: 128Mi
    requests:
      cpu: 50m
      memory: 64Mi
```

## Monitoring

### Enable Prometheus Metrics

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
```

### Available Metrics

| Metric | Description |
|--------|-------------|
| `redis_up` | Server status |
| `redis_connected_clients` | Connected clients |
| `redis_memory_used_bytes` | Memory used |
| `redis_commands_processed_total` | Processed commands |
| `redis_keyspace_hits_total` | Cache hits |
| `redis_keyspace_misses_total` | Cache misses |

### Grafana Dashboard

You can use the official Redis Exporter dashboard: [Grafana Dashboard 763](https://grafana.com/grafana/dashboards/763)

## Security

### Production Recommendations

1. **Use external Secrets** for passwords:
   ```yaml
   auth:
     enabled: true
     existingSecret: my-valkey-secret
   ```

2. **Enable Network Policies**:
   ```yaml
   networkPolicy:
     enabled: true
     allowExternal: false
   ```

3. **Configure resources**:
   ```yaml
   standalone:
     resources:
       limits:
         memory: 2Gi
       requests:
         memory: 1Gi
   ```

4. **Enable TLS** (if needed):
   ```yaml
   tls:
     enabled: true
     existingSecret: valkey-tls-secret
   ```

### Default Security Context

```yaml
podSecurityContext:
  fsGroup: 65532
  runAsUser: 65532
  runAsGroup: 65532

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 65532
```

## Troubleshooting

### Pod Won't Start

```bash
# View events
kubectl describe pod my-valkey-0

# View logs
kubectl logs my-valkey-0

# Check PVC
kubectl get pvc
```

### Connection Error

```bash
# Check service
kubectl get svc my-valkey

# Check endpoints
kubectl get endpoints my-valkey

# Connectivity test
kubectl run test --rm -it --image=busybox -- nc -zv my-valkey 6379
```

### StatefulSet Upgrade Error

`Forbidden: updates to statefulset spec` means the release changes a field
Kubernetes cannot update in place. Delete the StatefulSet yourself — pods and
PVCs survive `--cascade=orphan` — and upgrade again:

```bash
kubectl delete statefulset my-valkey --cascade=orphan
helm upgrade my-valkey valkey/valkey
```

In sentinel mode delete `-master` and `-replica` **one at a time**, waiting for
each to come back, and leave `-sentinel` alone: it has no volumes to preserve,
and restarting the sentinels alongside the data pods can leave the deployment
with no master.

### Check Sentinel Status

```bash
kubectl exec -it my-valkey-sentinel-0 -- valkey-cli -p 26379 SENTINEL masters
```

### Sentinel Mode Left With No Master

Symptom: every data pod reports `slave` of an address that no longer exists, the
sentinels report that same dead address, and starting pods sit in
`Waiting for a reachable master...`. It happens when the master, the replicas and
the sentinels all restart close together: the sentinels promote a replica that is
itself about to restart, and afterwards nobody answers at the promoted address.

From 0.3.2 this resolves itself. Each pod's startup loop waits at most
`2 × sentinel.downAfterMilliseconds + 10s` of wall clock for a reachable master
and then starts as master, giving the sentinels a live candidate. From 0.3.1 a
version bump no longer restarts every pod at once, so the situation is far less
likely to arise in the first place.

To resolve it by hand, **the order matters**. Live sentinels actively reconfigure
instances, so they will revert a manual promotion within seconds while they still
monitor the dead address. Restart the sentinels first, then promote:

```bash
# 1. Restart the sentinels so they discard the stale master address
kubectl delete pod -l app.kubernetes.io/component=sentinel

# 2. While they are down, promote the pod with the most authoritative data
#    (normally the master pod, which came back with its own volume)
kubectl exec my-valkey-master-0 -- valkey-cli -a "$PASSWORD" REPLICAOF NO ONE

# 3. The sentinels rediscover it on startup; replicas leave their wait loop
#    on their own once a master answers
```

Once a live master answers, clear the ghost replica the failover left behind —
`num-slaves` counts one more than exists — with `SENTINEL RESET` on each sentinel.
Do this **only** after the master is reachable: a reset re-resolves from the
configured address, which is useless while that address is dead.

## Uninstallation

```bash
# Uninstall release
helm uninstall my-valkey

# Delete PVCs (WARNING: this deletes data)
kubectl delete pvc -l app.kubernetes.io/instance=my-valkey
```

## Development

### Test Locally

```bash
# Validate syntax
helm lint .

# Render templates
helm template test . --debug

# Dry-run
helm install test . --dry-run --debug

# Install in test namespace
helm install test . -n valkey-test --create-namespace
```

### Run Tests

```bash
helm test my-valkey
```

## Contributing

1. Fork the repository
2. Create a branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to branch (`git push origin feature/new-feature`)
5. Create a Pull Request

## Links

- [Valkey Official](https://valkey.io/)
- [Valkey GitHub](https://github.com/valkey-io/valkey)
- [Artifact Hub](https://artifacthub.io/packages/helm/valkey-redis/valkey)
- [Chart Repository](https://github.com/start-codex/valkey-helm-chart)

## License

This project is licensed under [Apache 2.0](LICENSE).

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/start-codex">StartCodex</a>
</p>
