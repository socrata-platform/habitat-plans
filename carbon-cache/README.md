# Habitat package: carbon-cache

## Description

A package that builds on the base carbon package to define a carbon-cache service.

## Usage

For a basic service with an all-default configuration, just install the package and start the service:

```shell
hab pkg install socrata/carbon-cache
hab svc load socrata/carbon-cache
```

The process open file limit is set in the config's `[system]` table.

Settings for the `carbon.conf` file can be overridden or added by placing additional key/value pairs under the config's `[cache]` table.

Storage schemas can be configured by placing additional tables in the config's `[storage_schemas]` table.
