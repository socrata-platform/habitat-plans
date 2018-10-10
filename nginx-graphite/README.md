# Habitat package: nginx-graphite

## Description

A Habitat package for the Nginx instance that sits in front of graphite-web/uWSGI.

It wraps the [core/nginx](https://bldr.habitat.sh/#/pkgs/core/nginx) package with a basic Nginx config for listening on a configurable port and forwarding traffic to an upstream graphite-web service.

## Usage

For a basic service with an all-default configuration, install the package and start the service, binding it to a graphite-web instance.

```shell
hab pkg install socrata/nginx-graphite
hab svc load socrata/nginx-graphite --bind graphite-web:graphite-web.default
```

Note that the service requires access to graphite-web's Django media and content files, so both services must be run under the same Habitat supervisor or with a graphite-web container's directories mounted as read-only Docker volumes.

The master process listening port and open file limit can be configured under the `[master]` table. The worker count, file limit, and connection limit are under the `[workers]` table.
