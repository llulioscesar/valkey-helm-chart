# Valkey Helm Chart

Un Helm chart para desplegar Valkey en Kubernetes con soporte para modos standalone y sentinel con autenticación opcional.

## Características

- ✅ Modo standalone y sentinel
- ✅ Autenticación opcional
- ✅ Persistencia configurable
- ✅ Métricas opcionales con exportador Redis
- ✅ Configuración de recursos
- ✅ Políticas de red
- ✅ Configuración de seguridad
- ✅ Init containers para permisos de volumen
- ✅ Soporte para múltiples storage classes
- ✅ Actualizaciones automáticas transparentes con pre-upgrade hooks

## Instalación

### Opción 1: Instalación local (desarrollo/pruebas)

Si tienes el código del chart localmente:

```bash
# Sin autenticación
helm install valkey-standalone .

# Con autenticación
helm install valkey-standalone . \
  --set auth.enabled=true \
  --set auth.password=mipassword

# Modo sentinel
helm install valkey-sentinel . \
  --set architecture=sentinel \
  --set auth.enabled=true \
  --set auth.password=mipassword

# Con archivo de valores personalizado
helm install valkey-standalone . -f my-values.yaml
```

### Opción 2: Desde repositorio de Helm (producción)

```bash
# Agregar el repositorio
helm repo add valkey https://start-codex.github.io/valkey-helm-chart
helm repo update

# Instalar en modo standalone
helm install valkey-standalone valkey/valkey

# Con autenticación
helm install valkey-standalone valkey/valkey \
  --set auth.enabled=true \
  --set auth.password=mipassword

# Modo sentinel
helm install valkey-sentinel valkey/valkey \
  --set architecture=sentinel \
  --set auth.enabled=true \
  --set auth.password=mipassword
```

## Configuración

### Parámetros principales

| Parámetro | Descripción | Valor por defecto |
|-----------|-------------|-------------------|
| `architecture` | Arquitectura de despliegue (`standalone` o `sentinel`) | `standalone` |
| `auth.enabled` | Habilitar autenticación | `false` |
| `auth.password` | Contraseña para autenticación | `""` |
| `auth.existingSecret` | Secret existente con contraseña | `""` |

### Configuración de imagen

| Parámetro | Descripción | Valor por defecto |
|-----------|-------------|-------------------|
| `image.registry` | Registro de imagen | `docker.io` |
| `image.repository` | Repositorio de imagen | `valkey/valkey` |
| `image.tag` | Tag de imagen | `8.1.3` |
| `image.pullPolicy` | Política de descarga | `IfNotPresent` |

### Configuración standalone

| Parámetro | Descripción | Valor por defecto |
|-----------|-------------|-------------------|
| `standalone.replicaCount` | Número de réplicas | `1` |
| `standalone.persistence.enabled` | Habilitar persistencia | `true` |
| `standalone.persistence.size` | Tamaño del volumen | `8Gi` |
| `standalone.service.type` | Tipo de servicio | `ClusterIP` |
| `standalone.service.port` | Puerto del servicio | `6379` |

### Configuración sentinel

| Parámetro | Descripción | Valor por defecto |
|-----------|-------------|-------------------|
| `sentinel.enabled` | Habilitar sentinel | `false` |
| `sentinel.replicaCount` | Número de sentinels | `3` |
| `sentinel.quorum` | Quorum para failover | `2` |
| `master.replicaCount` | Número de masters | `1` |
| `replica.replicaCount` | Número de réplicas | `2` |

### Configuración de métricas

| Parámetro | Descripción | Valor por defecto |
|-----------|-------------|-------------------|
| `metrics.enabled` | Habilitar métricas | `false` |
| `metrics.serviceMonitor.enabled` | Habilitar ServiceMonitor | `false` |

## Ejemplos de uso

### Ejemplo 1: Valkey standalone básico

```yaml
# values.yaml
architecture: standalone
auth:
  enabled: false
standalone:
  persistence:
    enabled: true
    size: 10Gi
  resources:
    requests:
      memory: 256Mi
      cpu: 200m
    limits:
      memory: 512Mi
```

```bash
# Instalación local
helm install valkey-standalone . -f values.yaml

# Desde repositorio
helm install valkey-standalone valkey/valkey -f values.yaml
```

### Ejemplo 2: Valkey con autenticación

```yaml
# values.yaml
architecture: standalone
auth:
  enabled: true
  password: "mi-password-seguro"
standalone:
  persistence:
    enabled: true
    storageClass: "fast-ssd"
    size: 20Gi
```

```bash
# Instalación local
helm install valkey-auth . -f values.yaml

# Desde repositorio
helm install valkey-auth valkey/valkey -f values.yaml
```

### Ejemplo 3: Configuración sentinel con alta disponibilidad

```yaml
# values.yaml
architecture: sentinel
auth:
  enabled: true
  password: "password-ha"

sentinel:
  replicaCount: 3
  quorum: 2
  downAfterMilliseconds: 30000
  failoverTimeout: 180000

master:
  persistence:
    enabled: true
    size: 50Gi
  resources:
    requests:
      memory: 512Mi
      cpu: 500m
    limits:
      memory: 1Gi

replica:
  replicaCount: 2
  persistence:
    enabled: true
    size: 50Gi
  resources:
    requests:
      memory: 512Mi
      cpu: 500m
    limits:
      memory: 1Gi

metrics:
  enabled: true
  serviceMonitor:
    enabled: true
```

```bash
# Instalación local
helm install valkey-ha . -f values.yaml

# Desde repositorio
helm install valkey-ha valkey/valkey -f values.yaml
```

### Ejemplo 4: Con métricas y monitoreo

```yaml
# values.yaml
architecture: standalone
auth:
  enabled: true
  password: "password123"

metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s

standalone:
  persistence:
    enabled: true
    size: 15Gi
```

```bash
# Instalación local
helm install valkey-monitored . -f values.yaml

# Desde repositorio
helm install valkey-monitored valkey/valkey -f values.yaml
```

### Ejemplo 5: Configuración para entorno de desarrollo

```yaml
# install.yaml
architecture: standalone
auth:
  enabled: true
  existingSecret: redis-secret
  existingSecretPasswordKey: password
standalone:
  persistence:
    enabled: true
    size: 1Gi
    storageClass: "longhorn-simple"
  resources:
    requests:
      memory: 256Mi
      cpu: 100m
metrics:
  enabled: true
  podMonitor:
    enabled: true
```

```bash
# Instalación con configuración específica
helm install valkey-dev valkey/valkey -f install.yaml -n development
```

## Conectarse a Valkey

### Modo standalone

```bash
# Sin autenticación
kubectl run valkey-client --rm -it --image=valkey/valkey -- valkey-cli -h <release-name>-valkey

# Con autenticación
kubectl run valkey-client --rm -it --image=valkey/valkey -- valkey-cli -h <release-name>-valkey -a <password>
```

### Modo sentinel

```bash
# Conectar al master a través de sentinel
kubectl run valkey-client --rm -it --image=valkey/valkey -- valkey-cli -h <release-name>-valkey-sentinel -p 26379

# En el cliente sentinel:
# sentinel masters
# sentinel get-master-addr-by-name mymaster
```

## Actualización del Chart

Este chart incluye un mecanismo automático de actualización que maneja los StatefulSets de forma transparente.

### Proceso de actualización automática

Cuando actualizas el chart a una nueva versión, el sistema realiza automáticamente:

1. **Pre-upgrade Hook**: Antes de la actualización, se ejecuta un Job que elimina los StatefulSets existentes usando `--cascade=orphan`, preservando:
   - Los pods en ejecución
   - Los PersistentVolumeClaims (PVCs) con los datos
   - La disponibilidad del servicio

2. **Recreación de StatefulSets**: Helm recrea los StatefulSets con la nueva configuración

3. **Rolling Update**: Los pods se actualizan uno por uno (RollingUpdate) minimizando el tiempo de inactividad

### Cómo actualizar

```bash
# Actualizar desde repositorio
helm repo update
helm upgrade valkey-standalone valkey/valkey

# Actualizar con nuevos valores
helm upgrade valkey-standalone valkey/valkey -f new-values.yaml

# Actualizar instalación local
helm upgrade valkey-standalone .

# Actualizar con cambio de versión de imagen
helm upgrade valkey-standalone valkey/valkey \
  --set image.tag=8.1.4
```

### Configuración del hook de actualización

El hook de pre-upgrade se puede personalizar en `values.yaml`:

```yaml
preUpgradeHook:
  image:
    registry: docker.io
    repository: alpine/k8s  # Imagen Alpine con kubectl - gratuita y mantenida
    tag: "1.31.4"
    pullPolicy: IfNotPresent
  resources:
    limits:
      memory: 128Mi
    requests:
      cpu: 50m
      memory: 64Mi
```

### Notas importantes sobre actualizaciones

- Los datos en los PVCs se preservan durante las actualizaciones
- El proceso es completamente automático y transparente
- Los pods se actualizan gradualmente (uno a la vez) para mantener disponibilidad
- El hook solo se ejecuta durante upgrades, no en instalaciones nuevas
- Se requiere RBAC habilitado en el cluster (habilitado por defecto en la mayoría de clusters)

## Desinstalación

```bash
helm uninstall <release-name>
```

## Desarrollo

### Requisitos

- Helm 3.x
- Kubernetes 1.19+

### Probar el chart localmente

```bash
# Validar sintaxis
helm lint .

# Probar templates en modo standalone
helm template test . --set architecture=standalone

# Probar templates en modo sentinel
helm template test . --set architecture=sentinel --set auth.enabled=true --set auth.password=test

# Instalar localmente para pruebas
helm install test-valkey . --dry-run --debug
```

## Contribuir

1. Fork el repositorio
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Crea un Pull Request

## Licencia

Este proyecto está bajo la licencia MIT.