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
    NO_STATIC=1

# Install
make install PREFIX=${OPENBLAS_PREFIX}

# Create symlink for easy reference
ln -sf ${OPENBLAS_PREFIX} {install_prefix}/openblas-default

# Cleanup
cd /tmp
rm -rf OpenBLAS-${OPENBLAS_VERSION}*

echo "OpenBLAS {version} installed successfully"
EOF

USER ubuntu
