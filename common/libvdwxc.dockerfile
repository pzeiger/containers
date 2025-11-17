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
autoreconf -i
mkdir build && cd build

BUILD_FLAGS_C="{build_flags_c}"
BUILD_FLAGS_F="{build_flags_f}"

../configure --prefix=${LIBVDWXC_PREFIX} \
    --with-mpi=${MPICH_HOME} \
    --with-fftw3=${FFTW_DOUBLE_MPI_DIR}
    CFLAGS="${BUILD_FLAGS_C}" \
    FFLAGS="${BUILD_FLAGS_F}"
make -j{build_threads}
make check
make install

# Cleanup
cd /tmp
rm -rf libvdwxc

echo "✓ libvdwxc ${LIBVDWXC_VERSION} installed to ${LIBVDWXC_PREFIX}"
EOF






