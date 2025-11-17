USER root

# libxc {version} module - DFT exchange-correlation functionals library
RUN <<'EOF'
set -euxo pipefail

# Install dependencies
apt-get update
apt-get install -y \
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

# Configure with optimizations
./configure --prefix=${LIBXC_PREFIX} \
    --enable-shared \
    --disable-static \
    --enable-fortran \
    CFLAGS="-O3 -march=native" \
    FCFLAGS="-O3 -march=native"

# Build and install
make -j{build_threads}
make check
make install

# Create symlink for easy reference
ln -sf ${LIBXC_PREFIX} {install_prefix}/libxc-default

# Cleanup
cd /tmp
rm -rf libxc-${LIBXC_VERSION}*

echo "libxc {version} installed successfully"
EOF

USER ubuntu
WORKDIR /home/ubuntu
RUN << 'EOF'
which python
python setup.py install
EOF


