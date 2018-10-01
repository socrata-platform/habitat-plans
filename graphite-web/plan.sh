pkg_name=graphite-web
pkg_origin="${HAB_ORIGIN:-socrata}"
pkg_description="Graphite web"
pkg_upstream_url="https://github.com/graphite-project/graphite-web"
pkg_maintainer="Tyler Technologies, Data & Insights Division <sysadmin@socrata.com>"
pkg_license=("Apache-2.0")
# Pre-1.0 versions of the build-index script shell out to perl for their
# regexing.
pkg_deps=(
  core/bash
  core/cairo
  core/libxml2
  core/pcre
  core/perl
  core/python2
  core/zlib
  socrata/inspec
)
# The expat, fontconfig, freetype, glib, libpng, pixman, pkg-config, xlib,
# xproto, and zlib packages are all required to build pycairo and can be
# deleted when the version switches to one that uses cffi.
pkg_build_deps=(
  core/expat
  core/fontconfig
  core/freetype
  core/gcc
  core/glib
  core/libpng
  core/patchelf
  core/pixman
  core/pkg-config
  core/virtualenv
  core/xlib
  core/xproto
  socrata/carbon
)
pkg_bin_dirs=(bin)
pkg_binds=(
  [carbon-cache]="line_port storage_dir"
)
pkg_exports=(
  [port]=system.port
)
pkg_exposes=(
  port
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
  pip install pycairo pyparsing python-memcached pytz uwsgi whisper
  PYTHONPATH="${pkg_prefix}/webapp" pip install --no-binary=:all: \
    --install-option="--prefix=${pkg_prefix}" \
    --install-option="--install-lib=${pkg_prefix}/webapp" \
    graphite-web=="${pkg_version}"

  # Load the local_settings.py file from the config dir, which is in our
  # PYTHONPATH.
  sed -i 's/graphite\.local_settings/local_settings/g' \
    "${pkg_prefix}/webapp/graphite/settings.py"

  # The pre-1.0 build-index script doesn't respect an environment variable for
  # WHISPER_DIR if one is set.
  # shellcheck disable=SC2016
  local str='if [ "$WHISPER_DIR" = "" ]\nthen\n  WHISPER_DIR="${GRAPHITE_STORAGE_DIR}/whisper"\nfi'
  sed -i "\\,^WHISPER_DIR=,s,.*,${str}," "${pkg_prefix}/bin/build-index.sh"
  rm -rf "${pkg_prefix}/conf" "${pkg_prefix}/storage"
  cp -rp health "${pkg_prefix}/"
}

do_after() {
  local rpath
  rpath="$(pkg_path_for core/python2)/lib"
  rpath+=":$(pkg_path_for core/pcre)/lib"
  rpath+=":$(pkg_path_for core/libxml2)/lib"
  rpath+=":$(pkg_path_for core/zlib)/lib"

  patchelf --set-rpath "$rpath" "${pkg_prefix}/bin/uwsgi"
}
