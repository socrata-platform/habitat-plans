#!/bin/bash

set -eu

install_pre_commit () {
  # Ensure Pre-Commit is installed.
  if ! command -v pre-commit > /dev/null; then
    echo "[INFO] Pre-Commit not found; installing..."
    if command -v brew > /dev/null; then
      echo -n "    [INFO] Installing Pre-Commit via Homebrew..."
      brew update > /dev/null
      brew install pre-commit > /dev/null && echo " OK"
    elif command -v pip3 > /dev/null; then
      echo -n "    [INFO] Installing Pre-Commit via Pip and Virtualenv..."
      if ! command -v virtualenv > /dev/null; then
        pip3 install virtualenv > /dev/null
      fi
      sudo virtualenv /opt/pre-commit > /dev/null
      sudo /opt/pre-commit/bin/pip install pre-commit > /dev/null && echo " OK"
      sudo ln -s /opt/pre-commit/bin/pre-commit /usr/local/bin/pre-commit
    elif command -v apt-get > /dev/null; then
      echo -n "    [INFO] Installing Python via APT..."
      sudo apt-get update > /dev/null
      sudo apt-get -y install python3 python3-dev python3-pip > /dev/null && echo " OK"

      echo -n "    [INFO] Installing Pre-Commit via Pip and Virtualenv..."
      pip3 install virtualenv > /dev/null
      sudo virtualenv /opt/pre-commit > /dev/null
      sudo /opt/pre-commit/bin/pip install pre-commit > /dev/null && echo " OK"
      sudo ln -s /opt/pre-commit/bin/pre-commit /usr/local/bin/pre-commit
    else
      echo "[ERROR] Don't know how to install Pre-Commit on this platform"
      exit 1
    fi
  fi
}

install_shellcheck () {
  # Ensure ShellCheck is installed.
  if ! command -v shellcheck > /dev/null; then
    echo "[INFO] ShellCheck not found; installing..."
    if command -v brew > /dev/null; then
      echo -n "    [INFO] Installing ShellCheck via Homebrew..."
      brew install shellcheck > /dev/null && echo " OK"
    elif command -v apt-get > /dev/null; then
      echo -n "    [INFO] Installing ShellCheck via APT..."
      sudo apt-get update > /dev/null
      sudo apt-get -y install shellcheck > /dev/null && echo " OK"
    else
      echo "[ERROR] Don't know how to install ShellCheck on this platform"
      exit 1
    fi
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

run_pre_commit () {
  echo "[INFO] Installing Pre-Commit locally..."
  pre-commit install

  echo "[INFO] Running pre-commit on all files..."
  pre-commit run --all-files
}

main() {
  install_pre_commit
  install_shellcheck
  install_chefdk

  run_pre_commit
}

main

exit 0
