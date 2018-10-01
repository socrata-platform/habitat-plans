#!/usr/bin/env bash
#
# pre-commit hook:
# Lint any Ruby files with RuboCop
#
# Authors:
# - Jonathan Hartman <jonathan.hartman@tylertech.com>

set -eu

chef exec rubocop "$@"
