#!/bin/bash
set -euxo pipefail

# Get an updated config.sub and config.guess.
cp "$BUILD_PREFIX/share/libtool/build-aux/config.guess" \
   "$BUILD_PREFIX/share/libtool/build-aux/config.sub" .

# curl's configure script expects the include flags in CFLAGS.
export CFLAGS="$CFLAGS ${CPPFLAGS:-}"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"

if [[ "${target_platform}" == osx-* ]]; then
    ssl_options=(
        --with-openssl="$PREFIX"
        --with-default-ssl-backend=openssl
    )
else
    ssl_options=(--with-openssl="$PREFIX")
fi

./configure \
    --prefix="$PREFIX" \
    --host="$HOST" \
    --disable-ldap \
    --enable-websockets \
    --with-ca-bundle="$PREFIX/ssl/cacert.pem" \
    "${ssl_options[@]}" \
    --with-zlib="$PREFIX" \
    --with-zstd="$PREFIX" \
    --with-gssapi="$PREFIX" \
    --with-libssh2="$PREFIX" \
    --with-nghttp2="$PREFIX" \
    --with-libpsl

make -j"$CPU_COUNT"
make install

# Keep the original, prefix-relocatable curl-config as the source of truth,
# but put a wrapper in PATH. Outside a conda-style build, the wrapper prefers
# the host system's curl-config. This prevents tools such as Git's top-level
# Makefile from accidentally mixing the conda prefix's headers with a host
# compiler when a user merely has a conda environment activated.
mkdir -p "$PREFIX/libexec/curl"
mv "$PREFIX/bin/curl-config" "$PREFIX/libexec/curl/curl-config"
install -m 0755 "$RECIPE_DIR/curl-config-wrapper" "$PREFIX/bin/curl-config"

# curl installs manual pages and other documentation that are not packaged by
# the upstream conda-forge split recipe.
rm -rf "$PREFIX/share"
