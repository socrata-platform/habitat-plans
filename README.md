# Habitat-Plans

[![Build Status](https://img.shields.io/travis/com/socrata-platform/habitat-plans.svg)][travis]

[travis]: https://travis-ci.com/socrata-platform/habitat-plans

Socrata-maintained Habitat plans.

For information about an individual plan, see that directory's README.

## Requirements

Habitat must be installed. Also... TODO

## Usage

To build one of the plans locally, use the Habitat studio:

```bash
✗ HAB_ORIGIN=socrata hab studio enter
   hab-studio: Creating Studio at /hab/studios/src (default)
   hab-studio: Importing 'socrata' secret origin key
» Importing origin key from standard input
★ Imported secret origin key socrata-20171027204656.
   hab-studio: Importing 'socrata' public origin key
» Importing origin key from standard input
★ Imported public origin key socrata-20171027204656.
   hab-studio: Entering Studio at /hab/studios/src (default)
   hab-studio: Exported: HAB_ORIGIN=socrata

[1][default:/src:0]# build carbon-cache
[2][default:/src:1]# hab svc load socrata/carbon-cache
The socrata/carbon-cache service was successfully loaded
[3][default:/src:0]# hab svc start socrata/carbon-cache
[4][default:/src:0]# sup-log
```

## Maintainers

- Jonathan Hartman <jonathan.hartman@tylertech.com>
