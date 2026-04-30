[![ci](https://github.com/okdp/hive-metastore/actions/workflows/ci.yml/badge.svg)](https://github.com/okdp/hive-metastore/actions/workflows/ci.yml)
[![release-please](https://github.com/okdp/hive-metastore/actions/workflows/release-please.yml/badge.svg)](https://github.com/okdp/hive-metastore/actions/workflows/release-please.yml)
[![Release](https://img.shields.io/github/v/release/okdp/hive-metastore)](https://github.com/okdp/hive-metastore/releases/latest)&ensp;&ensp;
[![Helm](https://img.shields.io/badge/helm-3+-blue.svg)](https://helm.sh/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-1.19+-blue.svg)](https://kubernetes.io/)&ensp;&ensp;
[![License Apache2](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0)
<a href="https://okdp.io">
  <img src="https://okdp.io/logos/okdp-notext.svg" height="20px" style="margin: 0 2px;" />
</a>

An [Apache Hive Metastore](https://cwiki.apache.org/confluence/display/hive/design#Design-Metastore) Docker image and Helm chart for Kubernetes, part of the [OKDP](https://okdp.io) (Open Kubernetes Data Platform) ecosystem.

This repository contains:

- A **Dockerfile** and associated scripts to build the `hive-metastore` Docker image — published to [quay.io/okdp/hive-metastore](https://quay.io/repository/okdp/hive-metastore)
- A corresponding **Helm chart** — published to [quay.io/okdp/charts/hive-metastore](https://quay.io/repository/okdp/charts/hive-metastore)

A PostgreSQL server with an empty database is to be provided. An init job will take care of creating the DB schema.

Also, access to the target S3 service is required.

## Requirements

- Kubernetes cluster
- [Helm](https://helm.sh/) installed

## Installation

Refer to the [Helm chart README](helm/hive-metastore/README.md) for the customization and installation guide.

> [!NOTE]
> An OKDP sandbox with all these helm charts pre-installed and ready to use is available at [okdp-sandbox](https://github.com/OKDP/okdp-sandbox).

---

**Built for the OKDP Community**
<a href="https://okdp.io">
  <img src="https://okdp.io/logos/okdp-notext.svg" height="20px" style="margin: 0 2px;" />
</a>
