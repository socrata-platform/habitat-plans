pkg_name=openssl
pkg_description="The OpenSSL cryptography and SSL/TLS toolkit in FIPS mode"
pkg_origin=socrata
pkg_version=$(wget -q -O - https://www.openssl.org/source/ | \
              grep -E -o '>openssl-1\.0\.[0-9]+[a-z]\.tar\.gz<' | \
              sed -E 's/^>openssl-(1\.0\.[0-9]+[a-z])\.tar\.gz<$/\1/')
pkg_maintainer="Socrata Engineering <sysadmin@socrata.com>"
pkg_license=('OpenSSL')
pkg_upstream_url="https://www.openssl.org"
pkg_source="https://www.openssl.org/source/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum=$(wget -q -O - ${pkg_source}.sha256)

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

pkg_deps=(core/cacerts core/zlib socrata/openssl-fips)
pkg_build_deps=(core/coreutils core/diffutils core/gcc core/make core/perl)

do_prepare() {
  do_default_prepare

  # The tests need to be able to find rm in the coreutils package.
  build_line "Patching all references to '/bin/rm'"
  for file in $(grep -R '/bin/rm' ${SRC_PATH}/test/* | cut -d ':' -f 1 | sort | uniq); do
    debug "Patching file ${file}"
    sed -i 's,/bin/rm,rm,g' $file
  done

  export BUILD_CC=gcc
  export DO_CHECK=true
}

do_build() {
  ./config \
    --prefix="${pkg_prefix}" \
    --openssldir=ssl \
    --with-fipsdir="$(pkg_path_for openssl-fips)" \
    no-idea \
    no-mdc2 \
    no-rc5 \
    zlib \
    shared \
    disable-gost \
    fips \
    $CFLAGS \
    $LDFLAGS

  env CC= make depend
  make CC="$BUILD_CC"
}

do_check() {
  make test
}

do_install() {
  # Some of the tests rely on using demoCA, so this can't happen earlier.
  build_line "Patching in pointers to the cacerts package"
  sed -i "\,^certificate,s,\$dir/cacert\.pem,$(pkg_path_for cacerts)/ssl/certs/cacert.pem,g" \
    ${SRC_PATH}/apps/openssl.cnf
  sed -i "\,define X509_CERT_DIR,s,OPENSSLDIR \"/certs\",\"$(pkg_path_for cacerts)/ssl/certs\",g" \
    ${SRC_PATH}/crypto/cryptlib.h
  sed -i "\,define X509_CERT_FILE,s,OPENSSLDIR \"/cert\.pem\",\"$(pkg_path_for cacerts)/ssl/cert.pem\",g" \
    ${SRC_PATH}/crypto/cryptlib.h

  build_line "Patching out references to './demoCA'"
  sed -i "s,\./demoCA,${pkg_prefix}/ssl,g" ${SRC_PATH}/apps/CA.pl.in
  sed -i "s,\./demoCA,${pkg_prefix}/ssl,g" ${SRC_PATH}/apps/openssl.cnf
  sed -i "\,CATOP=\./demoCA,s,\./demoCA,${pkg_prefix}/ssl,g" ${SRC_PATH}/apps/CA.sh

  # Not all the tests pass in FIPS mode.
  build_line "Patching openssl.cnf to enable FIPS mode by default"
  ptch="openssl_conf = openssl_conf_section\n\n"
  ptch="${ptch}[ openssl_conf_section ]\n"
  ptch="${ptch}alg_section = algs\n\n"
  ptch="${ptch}[ algs ]\n"
  ptch="${ptch}fips_mode = yes\n\n"
  sed -i "\,^\[ new_oids \]$,s,^,${ptch}," ${SRC_PATH}/apps/openssl.cnf

  do_default_install
}
