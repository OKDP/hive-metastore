[![ci](https://github.com/okdp/hive-metastore/actions/workflows/ci.yml/badge.svg)](https://github.com/okdp/hive-metastore/actions/workflows/ci.yml)
[![release-please](https://github.com/okdp/hive-metastore/actions/workflows/release-please.yml/badge.svg)](https://github.com/okdp/hive-metastore/actions/workflows/release-please.yml)
[![License Apache2](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0)

<p align="center">
    <img width="400px" height=auto src="https://okdp.io/logos/okdp-inverted.png" />
</p>

This repo contains:

- A Dockerfile and associated scripts to build the `hive-metastore` docker image.
- A corresponding helm chart.

A postgresql server with an empty database is to be provided. An init job will take care of creating the DB schema.

Also, access to the target S3 service is required.

## Installation

Refer to [README](helm/superset/README.md) for the customization and installation guide.

## Requirements

- Kubernetes cluster
- [Helm](https://helm.sh/) installed

> [!NOTE]
> An OKDP sandbox, with all these helm charts installed, is under development and you can use it once released.
> 
