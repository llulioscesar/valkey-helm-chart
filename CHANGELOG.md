# Changelog


## [0.2.8] - 2026-09-11

### Fixed
- Sentinel mode: replicas could not replicate with auth enabled. Master and replicas now set both `requirepass` and `masterauth`, so a former master can rejoin as a replica after a failover.
- Sentinel mode: `sentinel.conf` was rendered only when `sentinel.enabled` was true, independently of `architecture: sentinel`; every sentinel restart appended another `monitor` line and looped on `Duplicate master name`. The file is now rendered for `architecture: sentinel`, and a restarted sentinel reuses `/tmp/sentinel.conf` when it already monitors the master.
- Sentinel mode: `sentinel monitor` pointed at the master Service IP, which always selects the original master pod, so clients kept going to a demoted node after a failover. Every pod now asks the sentinels for the current master, accepts the answer only if that address replies `ROLE` master, and on a fresh install finds the master through the headless Service.
- Sentinel mode: a restarted master pod could stay a replica of its own dead IP forever, and a starting sentinel could wait indefinitely on a dead master. Both cases are now handled by the reachability check and a headless scan.
- Sentinel mode: startup scripts waiting for a master were killed by the liveness and readiness probes before their wait ended, deadlocking the whole StatefulSet. Added `startupProbe` to master, replica and sentinel (5 minutes by default).
- `replica.affinity` referenced a helper that does not exist and broke rendering; it now uses `toYaml` like master and sentinel.
- Standalone with auth: the startup script used `cp`, which the Chainguard image does not ship, so Valkey started with a config containing only `requirepass` (`maxmemory-policy noeviction` instead of `allkeys-lru`). Replaced with a bash builtin.

### Changed
- Sentinel defaults: `parallelSyncs` 1 → 10 and `failoverTimeout` 180000 → 30000. Every pod restart leaves an `s_down` replica entry with the old IP in the sentinels. With `parallel-syncs 1` the failover leader can spend its only reconfiguration slot on one of those addresses, and the per-replica timeout is only evaluated while a slot is free, so the failover lasts the whole `failover-timeout`; meanwhile the leader still reports the old master in `SENTINEL MASTERS`. Measured: ~3.5 minutes without a master for clients querying the leader, ~31 seconds with the new defaults.


## [0.2.7] - 2026-03-09

### Changed
- Updated redis-exporter from v1.81.0 to v1.82.0


## [0.2.6] - 2026-03-02

### Changed
- Updated redis-exporter from  to v1.81.0


## [0.2.5] - 2026-02-25

### Changed
- Updated Valkey from 9.0.2 to 9.0.3 (from Chainguard latest image)
- Updated redis-exporter from  to v1.81.0


## [0.2.4] - 2026-02-23

### Changed
- Updated redis-exporter from  to v1.81.0

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.3] - 2026-02-15

### Changed
- Update redis-exporter from `v1.80.0` to `v1.81.0` (latest stable release)
- Remove bash dependency from metrics exporter in replica and sentinel templates
- Metrics exporter now uses native entrypoint instead of bash wrapper (cleaner, more portable)
- Simplified metrics configuration across all deployment modes

### Added
- Automated weekly version checking workflow for Valkey
- Documentation for image versioning strategy
- Complete CHANGELOG.md with release history

### Fixed
- Remove redundant password configuration in metrics exporter (was configured twice)

### Note
- Chainguard `prometheus-redis-exporter` image requires authentication (not in public free tier)
- Using `oliver006/redis_exporter:v1.81.0` for public accessibility
- Template improvements support both oliver006 and distroless images

## [0.2.1] - 2026-02-15

### Changed
- Updated Valkey to version 9.0.2 (from Chainguard latest image)

## [0.2.0] - 2025-02-14

### Changed
- Switch to Chainguard zero-CVE images for enhanced security (valkey, kubectl, wolfi-base)
- Update container user from 999 to 65532 (Chainguard default)
- Simplify health check scripts for distroless compatibility
- Update pre-upgrade hook to work without shell

### Added
- Automated version checking workflow (runs weekly)
- Documentation for image versioning strategy
- CHANGELOG.md for tracking releases

### Security
- Migration to Chainguard images with zero known CVEs
- Enhanced security with distroless base images

## [0.1.0] - 2024

### Added
- Initial release of Valkey Helm Chart
- Standalone mode support
- Sentinel mode for high availability
- Authentication and security features
- Persistence configuration
- Prometheus metrics exporter
- TLS support
- Pre-upgrade hooks for zero-downtime migrations
- Network policies and RBAC
- Comprehensive documentation

---

**Note**: Starting from v0.2.0, this chart uses `cgr.dev/chainguard/valkey:latest` and the `appVersion` is automatically updated weekly via GitHub Actions when new Valkey versions are released.
