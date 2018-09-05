# Habitat package: graphite-web

## Description

A Habitat package for Graphite's web service.

## Usage

By default, uWSGI exposes a socket file rather than a port. To have the Graphite components run under separate supervisors or as Docker containers, the socket needs to be overridden to an `IP:port`.
