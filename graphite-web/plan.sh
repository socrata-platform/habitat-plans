pkg_name=graphite-web
pkg_origin="${HAB_ORIGIN:-socrata}"
pkg_description="Graphite web"
pkg_upstream_url="https://github.com/graphite-project/graphite-web"
pkg_maintainer="Tyler Technologies, Data & Insights Division <sysadmin@socrata.com>"
pkg_license=("Apache-2.0")
pkg_deps=(
  core/bash
  core/pcre
  core/python2
)
pkg_build_deps=(
  core/gcc
  core/patchelf
  core/virtualenv
  "${pkg_origin}/carbon"
)
pkg_bin_dirs=(bin)
pkg_binds=(
  [carbon_cache]="line_port"
)

# The graphite-web version matches up to the Carbon version.
pkg_version() {
  < "$(pkg_path_for socrata/carbon)/IDENT" cut -d '/' -f 3
}

do_before() {
  do_default_before
  update_pkg_version
}

do_prepare() {
  virtualenv "${pkg_prefix}"
  # shellcheck source=/dev/null
  source "${pkg_prefix}/bin/activate"
}

do_build() {
  return 0
}

do_install() {
  pip install django==1.5.5
  pip install django-tagging==0.3.6
  pip install pytz pyparsing python-memcached uwsgi
  pip install graphite-web=="$pkg_version"
  rm -rf "${pkg_prefix}/conf"
}

do_after() {
  patchelf --set-rpath "$(pkg_path_for core/python2)/lib:$(pkg_path_for core/pcre)/lib" "${pkg_prefix}/bin/uwsgi"
}
