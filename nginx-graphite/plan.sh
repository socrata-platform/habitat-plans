pkg_name=nginx-graphite
pkg_origin="${HAB_ORIGIN:-socrata}"
pkg_description="An Nginx proxy for Graphite"
pkg_upstream_url="https://nginx.org"
pkg_maintainer="Tyler Technologies, Data & Insights Division <sysadmin@socrata.com>"
pkg_license=("BSD-2-Clause")
pkg_deps=(
  core/nginx
  socrata/graphite-web
)
pkg_binds=(
  [graphite-web]="port"
)
pkg_exports=(
  [port]=port
)
pkg_exposes=(
  port
)

# The package version is whatever version of Nginx we're building on top of.
pkg_version() {
  < "$(pkg_path_for core/nginx)/IDENT" cut -d '/' -f 3
}

do_before() {
  do_default_before
  update_pkg_version
}

do_build() {
  return 0
}

do_install() {
  cp -rp health "${pkg_prefix}/"
}
