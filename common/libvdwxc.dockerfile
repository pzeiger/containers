USER root

# common/libvdwxc.dockerfile
RUN <<'EOF'

# Set installation prefix
LIBVDWXC_VERSION={version}
LIBVDWXC_PREFIX={install_prefix}/libvdwxc-${LIBVDWXC_VERSION}

# Clone source
cd /tmp
rm -rf libvdwxc
wget https://gitlab.com/libvdwxc/libvdwxc/-/archive/${LIBVDWXC_VERSION}/libvdwxc-${LIBVDWXC_VERSION}.tar.gz
tar xzf libvdwxc-${LIBVDWXC_VERSION}.tar.gz
cd libvdwxc-${LIBVDWXC_VERSION}

# Build libvdwxc
sh autogen.sh
autoreconf -i
mkdir build && cd build

export CFLAGS="{build_flags_c}"
export FFLAGS="{build_flags_f}"
BUILD_FFTW3_INCLUDES="${FFTW_INCLUDE_DIR:-}"
BUILD_FFTW3_LIBS="${FFTW_LIBS_DIR:-}"

if [ -z "$BUILD_FFTW3_INCLUDES" ] || [ -z "$BUILD_FFTW3_LIBS" ]; then
    ../configure --prefix=${LIBVDWXC_PREFIX} \
        CC="mpicc" FC="mpif90" \
	--with-fftw3
else
    ../configure --prefix=${LIBVDWXC_PREFIX} \
        CC="mpicc" FC="mpif90" \
        FFTW3_INCLUDES="-I${BUILD_FFTW3_INCLUDES}" \
        FFTW3_LIBS="-L${BUILD_FFTW3_LIBS} -lfftw3 -lfftw3_mpi"
fi
make -j{build_threads}
make check
make install

ln -sf ${LIBVDWXC_PREFIX} {install_prefix}/libvdwxc-default
# Cleanup
cd /tmp
rm -rf libvdwxc

echo "✓ libvdwxc ${LIBVDWXC_VERSION} installed to ${LIBVDWXC_PREFIX}"
EOF

ENV LIBVDWXC_HOME={install_prefix}/libvdwxc-default
ENV LIBVDWXC_INCLUDE_DIR={install_prefix}/libvdwxc-default/include
ENV LIBVDWXC_LIBS_DIR={install_prefix}/libvdwxc-default/lib
ENV LD_LIBRARY_PATH=${LIBVDWXC_LIBS_DIR}:${LD_LIBRARY_PATH:-}
