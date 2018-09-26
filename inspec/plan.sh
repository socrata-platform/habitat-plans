pkg_name=inspec
pkg_origin="${HAB_ORIGIN:-socrata}"
pkg_version="2.2.112"
pkg_description="A minimal Chef Inspec"
pkg_upstream_url="https://inspec.io"
pkg_maintainer="Tyler Technologies, Data & Insights Division <sysadmin@socrata.com>"
pkg_license=("Apache-2.0")
pkg_deps=(
  core/busybox-static
  core/cacerts
  core/coreutils
  core/iproute2
  core/libxml2
  core/libxslt
  core/net-tools
  core/ruby
)
pkg_build_deps=(
  core/gcc
  core/make
)
pkg_bin_dirs=(bin)

do_prepare() {
  export GEM_HOME="$pkg_prefix/lib"
  export GEM_PATH="$GEM_HOME"
}

do_build() {
  return 0
}

do_install() {
  pushd "${HAB_CACHE_SRC_PATH}/${pkg_dirname}/" || exit 1
  gem install inspec -v "$pkg_version" --no-document
  popd || exit 1

  # Need to wrap the InSpec binary to ensure GEM_HOME/GEM_PATH is correct.
  local bin="$pkg_prefix/bin/$pkg_name"
  local real_bin="$GEM_HOME/gems/inspec-${pkg_version}/bin/inspec"
  cat <<EOF > "$bin"
#!$(pkg_path_for busybox-static)/bin/sh
export SSL_CERT_FILE=$(pkg_path_for cacerts)/ssl/cert.pem
set -e
export GEM_HOME="$GEM_HOME"
export GEM_PATH="$GEM_PATH"
exec $(pkg_path_for core/ruby)/bin/ruby $real_bin \$@
EOF
  chmod -v 755 "$bin"
}
