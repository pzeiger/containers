USER root

# libxc {version} module - DFT exchange-correlation functionals library
RUN <<'EOF'
set -euxo pipefail

# Install dependencies
apt-get update
apt-get install \
    build-essential \
    gfortran \
    wget \
    pkg-config

# Set installation prefix
LIBXC_PREFIX={install_prefix}/libxc-{version}
LIBXC_VERSION={version}

# Download and extract
cd /tmp
wget https://gitlab.com/libxc/libxc/-/archive/${LIBXC_VERSION}/libxc-${LIBXC_VERSION}.tar.gz
tar xf libxc-${LIBXC_VERSION}.tar.gz
cd libxc-${LIBXC_VERSION}

BUILD_FLAGS_C="{build_flags_c}"
BUILD_FLAGS_F="{build_flags_f}"

# Configure with optimizations
autoreconf -i
./configure --prefix=${LIBXC_PREFIX} \
    --enable-shared \
    --disable-static \
    --enable-fortran \
    CFLAGS="${BUILD_FLAGS_C}" \
    FFLAGS="${BUILD_FLAGS_F}"

# Build and install
make -j{build_threads}
make check
make install

# install python bindings
python setup.py install

# Create symlink for easy reference
ln -sf ${LIBXC_PREFIX} {install_prefix}/libxc-default

# Cleanup
cd /tmp
rm -rf libxc-${LIBXC_VERSION}*

echo "libxc {version} installed successfully"
EOF

