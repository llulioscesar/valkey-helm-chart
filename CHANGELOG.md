# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.2] - 2026-02-15

### Security
- **CRITICAL**: Switch redis-exporter to Chainguard image (eliminates 6 CVEs: 1 Critical, 4 High, 1 Medium)
- Changed from `docker.io/oliver006/redis_exporter:v1.80.0` to `cgr.dev/chainguard/prometheus-redis-exporter:latest`

### Added
- Automated weekly version checking workflow for Valkey
- Documentation for image versioning strategy
- Complete CHANGELOG.md with release history

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
