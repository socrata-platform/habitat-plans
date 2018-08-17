pkg_name=carbon
pkg_origin=socrata
pkg_version="0.9.12"
pkg_description="Graphite Carbon"
pkg_upstream_url="https://github.com/graphite-project/carbon"
pkg_maintainer="Tyler Technologies, Data & Insights Division <sysadmin@socrata.com>"
pkg_license=("Apache-2.0")
pkg_deps=(core/python2)
pkg_build_deps=(
  core/gcc
  core/virtualenv
)
pkg_bin_dirs=(bin)

do_prepare() {
  virtualenv "${pkg_prefix}"
  # shellcheck source=/dev/null
  source "${pkg_prefix}/bin/activate"
}

do_build() {
  return 0
}

do_install() {
  pip install Twisted==13.1.0
  pip install whisper
  pip install txAMQP
  PYTHONPATH="${pkg_prefix}/lib" pip install --no-binary=:all: \
    --install-option="--prefix=${pkg_prefix}" \
    --install-option="--install-lib=${pkg_prefix}/lib" \
    carbon==${pkg_version}
  rm -rf "${pkg_prefix}/conf"
}
