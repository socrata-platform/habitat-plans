# Habitat package: carbon

## Description

This package does a base installation of Graphite's Carbon with no additional configuration and no service definition. This can then be built upon and shared between separate packages for the carbon-cache, carbon-relay, and carbon-aggregator services.

It uses Python 2 and a virtualenv with all Python dependencies installed as part of this package, rather than as individual dependencies. This is to allow for a future version that installs the dependencies via Carbon's requirements.txt.

## Usage

Create a plan for a Carbon-derived service that depends on this package:

```shell
pkg_deps=("${pkg_origin}/carbon")
```
