USER root

# libxc {version} module - DFT exchange-correlation functionals library
RUN <<'EOF'

# Set installation prefix
LIBXC_PREFIX={install_prefix}/libxc-{version}
LIBXC_VERSION={version}

# Download and extract
cd /tmp
wget https://gitlab.com/libxc/libxc/-/archive/${LIBXC_VERSION}/libxc-${LIBXC_VERSION}.tar.gz
tar xf libxc-${LIBXC_VERSION}.tar.gz
cd libxc-${LIBXC_VERSION}

export CFLAGS="{build_flags_c}"
export FFLAGS="{build_flags_f}"

# Configure with optimizations
autoreconf -i
./configure --prefix=${LIBXC_PREFIX} \
    --enable-shared \
    --disable-static \
    --enable-fortran

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

ENV LIBXC_HOME={install_prefix}/libxc-default
ENV LIBXC_INCLUDE_DIR={install_prefix}/libxc-default/include
ENV LIBXC_LIBS_DIR={install_prefix}/libxc-default/lib
ENV LD_LIBRARY_PATH=${LIBXC_LIBS_DIR}:${LD_LIBRARY_PATH:-}
