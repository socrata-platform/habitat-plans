pkg_name=openssl-fips
pkg_description="The OpenSSL FIPS module"
pkg_origin=socrata
pkg_version=2.0.16
pkg_maintainer="Socrata Engineering <sysadmin@socrata.com>"
pkg_license=('OpenSSL')
pkg_upstream_url="https://www.openssl.org"
pkg_source="https://www.openssl.org/source/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum=a3cd13d0521d22dd939063d3b4a0d4ce24494374b91408a05bdaca8b681c63d4

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
  sed -i 's,/bin/rm,rm,g' "${pkg_prefix}/bin/fipsld"
}
