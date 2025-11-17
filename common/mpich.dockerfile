USER root

# MPICH {version} module - Message Passing Interface implementation
RUN <<'EOF'

# Install dependencies
apt-get update
apt-get install \
    build-essential \
    gfortran \
    wget \
    libhwloc-dev \
    libxml2-dev

# Set installation prefix
MPICH_PREFIX={install_prefix}/mpich-{version}
MPICH_VERSION={version}

# Download and extract
cd /tmp
wget http://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz
tar xf mpich-${MPICH_VERSION}.tar.gz
cd mpich-${MPICH_VERSION}

# Configure with optimizations
./configure --prefix=${MPICH_PREFIX} \
    --enable-fast=O3 \
    --enable-shared \
    --disable-static \
    --with-device=ch3:nemesis \
    --enable-fortran=all \
    --enable-cxx \
    CFLAGS="-O3 -march=native" \
    CXXFLAGS="-O3 -march=native" \
    FFLAGS="-O3 -march=native" \
    FCFLAGS="-O3 -march=native"

# Build and install
make -j{build_threads}
make install

# Create symlink for easy reference
ln -sf ${MPICH_PREFIX} {install_prefix}/mpich-default

# Cleanup
cd /tmp
rm -rf mpich-${MPICH_VERSION}*

echo "MPICH {version} installed successfully"
EOF


USER ubuntu
RUN << 'EOF'
wget https://raw.githubusercontent.com/PDC-support/introduction-to-pdc/master/example/hello_world_mpi.c
mpicc -fopenmp -o /home/ubuntu/bin/hello_world_mpi hello_world_mpi.c
hello_world_mpi

EOF

#ENV PATH=$PATH:/opt/mpich-$MPICH_VERSION/bin
#ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/mpich-$MPICH_VERSION/lib


WORKDIR ..
