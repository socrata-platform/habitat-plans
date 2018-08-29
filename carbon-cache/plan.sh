pkg_name=carbon-cache
pkg_origin="${HAB_ORIGIN:-python2}"
pkg_description="Graphite carbon-cache"
pkg_upstream_url="https://github.com/graphite-project/carbon"
pkg_maintainer="Tyler Technologies, Data & Insights Division <sysadmin@socrata.com>"
pkg_license=("Apache-2.0")
pkg_deps=(
  core/bash
  "${pkg_origin}/carbon"
)
pkg_exports=(
  [line_port]=cache.line_receiver_port
  [pickle_port]=cache.pickle_receiver_port
  [query_port]=cache.cache_query_port
)
pkg_exposes=(
  line_port
  pickle_port
  query_port
)

# The package version is whatever version of Carbon we're building on top of.
pkg_version() {
  < "$(pkg_path_for socrata/carbon)/IDENT" cut -d '/' -f 3
}

do_before() {
  do_default_before
  update_pkg_version
}

do_build() {
  return 0
}

do_install() {
  return 0
}
