pkg_name=openssl-fips
pkg_description="The OpenSSL FIPS module"
pkg_origin=socrata
pkg_version=$(wget -q -O - https://www.openssl.org/source/ | \
              grep -E -o '>openssl-fips-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz<' | \
              sed -E 's/^>openssl-fips-([0-9]+\.[0-9]+\.[0-9]+)\.tar\.gz<$/\1/')
pkg_maintainer="Socrata Engineering <sysadmin@socrata.com>"
pkg_license=('OpenSSL')
pkg_upstream_url="https://www.openssl.org"
pkg_source="https://www.openssl.org/source/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum=$(wget -q -O - ${pkg_source}.sha256)

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)

pkg_deps=(core/glibc)
pkg_build_deps=(core/coreutils core/gcc core/make core/perl)

do_build() {
  export FIPSDIR=$pkg_prefix
  ./config
  make
}

do_install() {
  do_default_install
  # Do this after the install to be on the safe side of satisfying "you cannot
  # modify the contents of the official tarball".
  sed -i 's,/bin/rm,rm,g' ${pkg_prefix}/bin/fipsld
}
