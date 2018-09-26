#!/bin/bash

set -eu

install_habitat() {
  # Ensure Habitat is installed.
  if ! command -v hab > /dev/null; then
    echo "[INFO] Habitat not found; installing..."
    if command -v brew > /dev/null; then
      echo -n "    [INFO] Installing Habitat via Homebrew..."
      brew tap habitat-sh/habitat > /dev/null
      brew install hab > /dev/null && echo " OK"
    else
      echo -n "    [INFO] Installing Habitat via curl..."
      # The gpg key import in Hab's install script sends some stuff to stderr.
      curl -s https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash > /dev/null 2>&1 && echo " OK"
    fi
  fi

  if ! hab origin key export "$HAB_ORIGIN" > /dev/null 2>&1; then
    echo -n "[INFO] Generating a test Habitat signging key for origin $HAB_ORIGIN..."
    hab origin key generate "$HAB_ORIGIN" > /dev/null && echo " OK"
  fi
}

install_chefdk() {
  # Ensure Chef-DK is installed.
  if ! command -v chef > /dev/null; then
    echo "[INFO] Chef-DK not found; installing..."
    if command -v brew > /dev/null; then
      echo -n "    [INFO] Installing Chef-DK via Homebrew..."
      brew tap chef/chef > /dev/null
      brew cask install chefdk > /dev/null && echo " OK"
    else
      echo -n "    [INFO] Installing Chef-DK via curl..."
      curl -s https://omnitruck.chef.io/install.sh | sudo bash -s -- -c current -P chefdk > /dev/null
    fi
  fi
  chef exec bundle install > /dev/null
}

run_kitchen () {
  plan="$1"

  install_habitat
  install_chefdk

  echo "[INFO] Building a test artifact for ${plan}..."
  hab studio build "$plan"

  echo "[INFO] Running Test Kitchen for ${plan}..."
  chef exec kitchen test -d always
}

main() {
  export HAB_ORIGIN="${HAB_ORIGIN:-socratest}"

  # Run pre-commit and Kitchen if this isn't a Travis build.
  if [ "${TRAVIS:-x}" = "x" ]; then
    "$(dirname "$0")/pre-commit.sh"
    if [ -n "$(git diff master "$HAB_PLAN")" ]; then
      run_kitchen "$HAB_PLAN"
    fi
  # Run pre-commit if no plan variable is set.
  elif [ "${HAB_PLAN:-x}" = "x" ]; then
    "$(dirname "$0")/pre-commit.sh"
  # If the build is a cron, every plan should be integration tested.
  elif [ "$TRAVIS_EVENT_TYPE" = "cron" ]; then
    run_kitchen "$HAB_PLAN"
  # Otherwise, only integration test the plans that this PR/merge has changed.
  else
    if [ -n "$(git diff "$TRAVIS_COMMIT_RANGE" "$HAB_PLAN")" ]; then
      run_kitchen "$HAB_PLAN"
    fi
  fi
}

main

exit 0
