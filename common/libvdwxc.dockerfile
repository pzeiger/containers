USER root

# common/libvdwxc.dockerfile
RUN <<'EOF'

# Install build dependencies
apt-get update
apt-get install \
    build-essential \
    cmake \
    wget \
    pkg-config

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

tail -f config.log &

BUILD_FLAGS_C="{build_flags_c}"
BUILD_FLAGS_F="{build_flags_f}"

../configure --prefix=${LIBVDWXC_PREFIX} \
    CC="mpicc" FC="mpif90" \
    FFTW3_INCLUDES="-I${FFTW_DOUBLE_MPI_INCLUDE_DIR}" \
    FFTW3_LIBS="-L${FFTW_DOUBLE_MPI_LIBS_DIR} -lfftw3 -lfftw3_mpi" \
    CFLAGS="${BUILD_FLAGS_C}" \
    FFLAGS="${BUILD_FLAGS_F}"
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
