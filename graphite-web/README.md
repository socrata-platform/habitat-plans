# Habitat package: graphite-web

## Description

A package that installs and configures the graphite-web service.

It uses Python 2 and a virtualenv with all Python dependencies installed as part of this package rather than as individual dependencies. This is to allow for a future version that installs the dependencies via Graphite-Web's requirements.txt.

## Usage

For a basic service with an all-default configuration, install the package and start the service, binding it to a carbon-cache instance.

```shell
hab pkg install socrata/graphite-web
hab svc load socrata/graphite-web --bind carbon-cache:carbon-cache.default
```

Note that the service requires access to the carbon-cache service's whisper files. Both services must be run under the same Habitat supervisor, or a graphite-web container needs to have the carbon-cache container's storage directory mounted as a read-only Docker volume.

The process open file limit, number of workers, and listening port are configured under the `[system]` table.

Settings for the `local_settings.py` file can be overridden or added by placing additional key/value pairs under the config's `[web]` table.

Databases can be configured by placing additional tables under the config's `[databases]` table.

Graph templates can be configured by placing additional tables under the config's `[graph_templates]` table.
