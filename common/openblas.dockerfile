USER root

# OpenBLAS {version} module - Optimized linear algebra library
RUN <<'EOF'

# Install dependencies
apt-get update
apt-get install \
    build-essential \
    gfortran \
    libgomp1 \
    wget

# Set installation prefix
OPENBLAS_PREFIX={install_prefix}/openblas-{version}
OPENBLAS_VERSION={version}

# Compilation flags (can be overridden via YAML variables)
OPENBLAS_CFLAGS="{build_flags_c}"
OPENBLAS_FFLAGS="{build_flags_f}"
OPENBLAS_CXXFLAGS="{build_flags_cxx}"
OPENBLAS_TARGET="{openblas_target}"

# Build with configurable flags
echo "Building OpenBLAS with:"
echo "  CFLAGS: ${OPENBLAS_CFLAGS}"
echo "  FFLAGS: ${OPENBLAS_FFLAGS}"
echo "  TARGET: ${OPENBLAS_TARGET}"

# Download and extract
cd /tmp
wget https://github.com/xianyi/OpenBLAS/releases/download/v${OPENBLAS_VERSION}/OpenBLAS-${OPENBLAS_VERSION}.tar.gz
tar xf OpenBLAS-${OPENBLAS_VERSION}.tar.gz
cd OpenBLAS-${OPENBLAS_VERSION}

# Compile with optimizations
# USE_OPENMP=1: Enable OpenMP parallelization
# DYNAMIC_ARCH=1: Enable dynamic architecture detection
# NUM_THREADS=64: Max threads
make -j{build_threads} \
    USE_OPENMP=1 \
    DYNAMIC_ARCH=1 \
    NUM_THREADS=64 \
    NO_STATIC=1 \
    TARGET=${OPENBLAS_TARGET} \
    CFLAGS="${OPENBLAS_CFLAGS}" \
    FFLAGS="${OPENBLAS_FFLAGS}" \
    CXXFLAGS="${OPENBLAS_CXXFLAGS}"

# Install
make install PREFIX=${OPENBLAS_PREFIX}

# Create symlink for easy reference
ln -sf ${OPENBLAS_PREFIX} {install_prefix}/openblas-default

# Cleanup
cd /tmp
rm -rf OpenBLAS-${OPENBLAS_VERSION}*

echo "OpenBLAS {version} installed successfully"
EOF

ENV OPENBLAS_HOME={install_prefix}/openblas-default
ENV LD_LIBRARY_PATH={install_prefix}/openblas-default/lib:${LD_LIBRARY_PATH}
