# Habitat Plan Testing

This document describes the process for testing Socrata Habitat plans.

## Prerequisites

In addition to Habitat itself, a working Chef Workstation or Chef Development Kit installation is required. The included `test/full.sh` test script makes a best effort attempt to install these applications, or they can be installed directly.

Habitat can be installed via...

- Direct [download](https://www.habitat.sh/docs/install-habitat/)
- Homebrew (`brew tap habitat-sh/habitat && brew install hab`)
- Chocolatey (`choco install habitat`)
- Shell script (documented [here](https://www.habitat.sh/docs/install-habitat/))
- The [habitat cookbook](https://supermarket.chef.io/cookbooks/habitat)

Chef Workstation can be installed via...

- Direct [download](https://downloads.chef.io/chef-workstation/)
- Homebrew (`brew cask install chef-workstation`)
- Chocolatey (`choco install chef-workstation`)
- APT/YUM/shell script (documented [here](https://docs.chef.io/packages.html))
- The [chef-ingredient cookbook](https://supermarket.chef.io/cookbooks/chef-ingredient)

The Chef-DK can be installed via...

- Direct [download](https://downloads.chef.io/chef-dk/)
- Homebrew (`brew cask install chefdk`)
- Chocolatey (`choco install chefdk`)
- APT/YUM/shell script (documented [here](https://docs.chef.io/packages.html))
- The [chefdk cookbook](https://supermarket.chef.io/cookbooks/chefdk)
- The [chef-dk cookbook](https://supermarket.chef.io/cookbooks/chef-dk)
- The [chef-ingredient cookbook](https://supermarket.chef.io/cookbooks/chef-ingredient)

The integration tests assume a running instance of Docker on the test machine. Docker can be installed via

- Direct [download](https://store.docker.com/search?type=edition&offering=community)
- Homebrew (`brew cask install docker`)
- Chocolatey (`choco install docker`)
- APT (documented [here](https://docs.docker.com/install/linux/docker-ce/ubuntu/))
- YUM (documented [here](https://docs.docker.com/install/linux/docker-ce/centos/))
- The [docker cookbook](https://supermarket.chef.io/cookbooks/docker)

## Installing Dependencies

Every Ruby gem required for testing is included as a part of the Chef-DK.

## All Tests

A script is provided for running all tests on a particular plan:

```shell
HAB_PLAN=<plan_name> test/full.sh
```

## Pre-Commit

Pre-Commit is used to run a series of tests, everything except (for the purpose of time) integration tests:

- A check for the addition of large files
- A check for merge conflicts
- A check for broken symlinks
- A check for invalid YAML
- A check for files without ending new lines
- A check for trailing whitespace
- The ShellCheck linter for plan files
- A check for missing default variables in plans
- A check for missing plan entries in the .bldr.toml
- A check for Habitat hook script anti-patterns
- The RuboCop linter for all Ruby files

A script is provided that will install ShellCheck and install and run Pre-Commit:

```shell
test/pre-commit.sh
```

Or, to run Pre-Commit by itself:

```shell
pre-commit install
pre-commit run --all-files
```

## Test Kitchen

Integration testing is done with Test Kitchen and Docker. The main test fixture cookbook lives in `test/fixtures/cookvooks/hab_test` and handles the installation of Habitat, starting of the supervisor, and building and installation of a given plan.

Each Habitat plan must have an additional cookbook in `plan-name/test/fixtures/cookbooks/plan_name_test` to handle any additional work such as starting up the Habitat services and binds.

The Inspec tests for a plan live in `plan-name/test/integration`.

To just run Test Kitchen for a particular plan:

```shell
HAB_ORIGIN=socrata HAB_PLAN=plan-name chef exec kitchen test
```
