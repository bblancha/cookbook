VERSION=8.0.0938
TAR=https://github.com/vim/vim/archive/v$VERSION.tar.gz
#BUILD_DEPENDS=(zlib curl openssl expat)

export AR="${HOST}-ar"
export AS="${HOST}-as"
export CC="${HOST}-gcc"
export CXX="${HOST}-g++"
export LD="${HOST}-ld"
export NM="${HOST}-nm"
export OBJCOPY="${HOST}-objcopy"
export OBJDUMP="${HOST}-objdump"
export RANLIB="${HOST}-ranlib"
export READELF="${HOST}-readelf"
export STRIP="${HOST}-strip"

#MAKEFLAGS="NO_MMAP=1 NEEDS_SSL_WITH_CURL=1 NEEDS_CRYPTO_WITH_SSL=1 NO_UNIX_SOCKETS=1 NO_POLL=1 NEEDS_LIBICONV= NEEDS_LIBRT= BLK_SHA1=1"

function recipe_version {
    echo "$VERSION"
    skip=1
}

function recipe_update {
    echo "skipping update"
    skip=1
}

function recipe_build {
    sysroot="${PWD}/../sysroot"
    export LDFLAGS="-L$sysroot/lib"
    export CPPFLAGS="-I$sysroot/include"

    echo "vim_cv_getcwd_broken=no
    vim_cv_memmove_handles_overlap=yes
    vim_cv_stat_ignores_slash=no
    vim_cv_terminfo=yes
    vim_cv_toupper_broken=no
    vim_cv_tty_group=world
    vim_cv_tgent=zero" >> src/auto/config.cache

    ./configure \
        --build=${HOST} \
        --host \
        --prefix=/tools \
        --enable-gui=no \
        --disable-gtktest \
        --disable-xim \
        --disable-gpm \
        --without-x \
        --disable-netbeans \
        --with-tlib=ncurses
#    ./configure --host=${HOST} --prefix=/ ac_cv_fread_reads_directories=yes ac_cv_snprintf_returns_bogus=yes ac_cv_lib_curl_curl_global_init=yes CURL_CONFIG=no
#    make ${MAKEFLAGS}
    make
    skip=1
}

function recipe_test {
    echo "skipping test"
    skip=1
}

function recipe_clean {
    make clean
    skip=1
}

function recipe_stage {
    dest="$(realpath $1)"
    make DESTDIR="$dest" ${MAKEFLAGS} install
    ${STRIP} $1/src/* || true
#    ${STRIP} $1/libexec/git-core/* || true
    rm -rf $1/share/man
    skip=1
}
