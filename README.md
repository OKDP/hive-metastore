[![ci](https://github.com/OKDP/hive-metastore/actions/workflows/ci.yml/badge.svg)](https://github.com/OKDP/hive-metastore/actions/workflows/ci.yml)
[![release-please](https://github.com/OKDP/hive-metastore/actions/workflows/release-please.yml/badge.svg)](https://github.com/OKDP/hive-metastore/actions/workflows/release-please.yml)&ensp;&ensp;
[![Release](https://img.shields.io/github/v/release/OKDP/hive-metastore)](https://github.com/OKDP/hive-metastore/releases/latest)
[![License Apache2](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0)
<a href="https://okdp.io">
  <img src="https://okdp.io/logos/okdp-notext.svg" height="20px" style="margin: 0 2px;" />
</a>

<p align="center">
    <img width="400px" height="auto" src="https://okdp.io/logos/okdp-inverted.png" />
</p>

Apache Hive Metastore Docker image and Helm chart for Kubernetes, with a PostgreSQL backend, an S3 warehouse and a Prometheus JMX exporter — published to [`quay.io/okdp`](https://quay.io/organization/okdp).

## What is OKDP Hive Metastore?

This repository builds and publishes:

- A **Docker image** ([`docker/Dockerfile`](docker/Dockerfile)) → [`quay.io/okdp/hive-metastore`](https://quay.io/repository/okdp/hive-metastore)
- A **Helm chart** ([`helm/hive-metastore/`](helm/hive-metastore/)) → [`quay.io/okdp/charts/hive-metastore`](https://quay.io/repository/okdp/charts/hive-metastore)

Key characteristics:

- **Built from the upstream Apache Hive standalone metastore distribution** — the Dockerfile supports both **Hive 3.x** (`hive-standalone-metastore`) and **Hive 4.x** (`hive-standalone-metastore-server`) via the selector at [`docker/Dockerfile#L60-L64`](docker/Dockerfile#L60-L64). The versions built by CI are listed in [`docker/metastore_4x.version`](docker/metastore_4x.version). Hadoop `3.3.6` ([`docker/Dockerfile#L19`](docker/Dockerfile#L19)).
- **PostgreSQL backend with automatic schema initialisation** — the chart ships a `post-install` / `post-upgrade` Job ([`helm/hive-metastore/templates/job.yaml`](helm/hive-metastore/templates/job.yaml)) that runs `schematool -initSchema` ([`docker/metastore.sh#L304-L314`](docker/metastore.sh#L304-L314)) if the `DBS` table is missing. PostgreSQL JDBC driver `42.7.7` is bundled ([`docker/Dockerfile#L21`](docker/Dockerfile#L21)).
- **S3 warehouse via `s3a://`** — accepts any S3-compatible endpoint (AWS S3, SeaweedFS) configured through [`helm/hive-metastore/values.yaml`](helm/hive-metastore/values.yaml) (`s3.url`, `s3.warehouseDirectory`, `s3.accessKey`, `s3.secretKey`).
- **Prometheus JMX metrics** exposed on port `9025` ([`docker/Dockerfile#L26`](docker/Dockerfile#L26), [`docker/config.yaml`](docker/config.yaml)) via the [`jmx_prometheus_javaagent`](https://github.com/prometheus/jmx_exporter) Java agent.
- **Multi-arch images** for `linux/amd64` and `linux/arm64` ([`.github/workflows/docker-build-test-push-template.yml#L138`](.github/workflows/docker-build-test-push-template.yml#L138)).
- **Network policy enabled by default** ([`helm/hive-metastore/values.yaml`](helm/hive-metastore/values.yaml) — `networkPolicies.enabled: true`) — the Thrift port `9083` is only reachable from explicitly allowed namespaces, since the metastore has no built-in authentication.

## Components

| Artifact | Registry | Description |
|:---------|:---------|:------------|
| Docker image | [`quay.io/okdp/hive-metastore`](https://quay.io/repository/okdp/hive-metastore) | Apache Hive standalone metastore, PostgreSQL/MySQL JDBC drivers, S3A connector, JMX exporter. |
| Helm chart | [`quay.io/okdp/charts/hive-metastore`](https://quay.io/repository/okdp/charts/hive-metastore) | Kubernetes deployment with init Job, NetworkPolicy, HPA, ServiceAccount, optional load-balancer / NodePort exposure. |

## Prerequisites

- Kubernetes cluster (>= 1.19)
- [Helm](https://helm.sh/) >= 3
- A PostgreSQL server with an empty database (the init Job will create the schema automatically)
- An S3-compatible endpoint reachable from the cluster

## Quick Start

The Helm chart cannot be installed standalone — it requires a PostgreSQL server and an S3 endpoint to be reachable from the cluster, plus Kubernetes Secrets holding the database password and S3 credentials.

For a ready-to-use environment with PostgreSQL, SeaweedFS (S3) and `hive-metastore` already wired together, see the [**OKDP sandbox**](https://github.com/OKDP/okdp-sandbox).

Installation on an existing infrastructure:

```sh
helm install my-release oci://quay.io/okdp/charts/hive-metastore \
  --version 1.4.0 \
  --namespace hive-metastore --create-namespace \
  -f values.yaml
```

A complete reference of the chart values is available in the [Helm chart README](helm/hive-metastore/README.md).

## Verify your deployment

Once the release is installed, the init Job and the metastore Deployment should be `Ready`:

```sh
kubectl -n hive-metastore get pods
# NAME                              READY   STATUS      RESTARTS   AGE
# my-release-hive-metastore-...     1/1     Running     0          1m
# my-release-hive-metastore-...     1/1     Running     0          1m
# my-release-hive-metastore-init-…  0/1     Completed   0          1m
```

The init Job logs should end with:

```sh
kubectl -n hive-metastore logs job/my-release-hive-metastore-init
# DATABASE SCHEMA SHOULD BE OK NOW!!
```

The metastore Thrift endpoint listens on port `9083` ([`docker/Dockerfile#L183`](docker/Dockerfile#L183)). From a pod inside an allowed namespace ([`networkPolicies.allowedNamespace`](helm/hive-metastore/values.yaml)):

```sh
nc -zv my-release-hive-metastore.hive-metastore.svc.cluster.local 9083
# Connection to … 9083 port [tcp/*] succeeded!
```

## Build and release workflow

Build and publication are fully automated via GitHub Actions:

- [`.github/workflows/ci.yml`](.github/workflows/ci.yml) — on every PR and push: build the Docker image for each version listed in [`docker/metastore_4x.version`](docker/metastore_4x.version), lint the Helm chart, run [`chart-testing`](https://github.com/helm/chart-testing).
- [`.github/workflows/release-please.yml`](.github/workflows/release-please.yml) — on merge to `main`, [release-please](https://github.com/googleapis/release-please) opens a release PR that bumps versions and updates the `CHANGELOG`. When the release PR is merged, the Docker image is pushed to `quay.io/okdp/hive-metastore` and the Helm chart to `quay.io/okdp/charts/hive-metastore`.
- [`.github/workflows/docker-rebuild.yml`](.github/workflows/docker-rebuild.yml) — weekly rebuild of the latest release tag (Tuesday 05:00 UTC) to pick up upstream base image security patches.
- [`.github/workflows/trivy.yml`](.github/workflows/trivy.yml) — vulnerability scan via [Trivy](https://github.com/aquasecurity/trivy) on every push to `main` and on every pull request.

---

**Built for the OKDP Community**
<a href="https://okdp.io">
  <img src="https://okdp.io/logos/okdp-notext.svg" height="20px" style="margin: 0 2px;" />
</a>
