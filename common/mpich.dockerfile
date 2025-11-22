USER root

# MPICH {version} module - Message Passing Interface implementation
RUN <<'EOF'

# Set installation prefix
MPICH_PREFIX={install_prefix}/mpich-{version}
MPICH_VERSION={version}

# Download and extract
cd /tmp
wget http://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz
tar xf mpich-${MPICH_VERSION}.tar.gz
cd mpich-${MPICH_VERSION}

export CFLAGS="{build_flags_c}"
export CXXFLAGS="{build_flags_cxx}"
export FFLAGS="{build_flags_f}"

# Configure with optimizations
./configure --prefix=${MPICH_PREFIX} \
    --enable-fast=O3 \
    --enable-shared \
    --disable-static \
    --with-device=ch3:nemesis \
    --enable-fortran=all \
    --enable-cxx

# Build and install
make -j{build_threads}
make install

# Create symlink for easy reference
ln -sf ${MPICH_PREFIX} {install_prefix}/mpich-default

# Create symlinks in /usr/local/bin for easy access
#ln -sf ${MPICH_PREFIX}/bin/mpicc /usr/local/bin/mpicc
#ln -sf ${MPICH_PREFIX}/bin/mpif90 /usr/local/bin/mpif90
#ln -sf ${MPICH_PREFIX}/bin/mpirun /usr/local/bin/mpirun
#ln -sf ${MPICH_PREFIX}/bin/mpiexec /usr/local/bin/mpiexec

# Cleanup
cd /tmp
rm -rf mpich-${MPICH_VERSION}*

echo "MPICH {version} installed successfully"
EOF

ENV MPICH_HOME={install_prefix}/mpich-default
ENV PATH={install_prefix}/mpich-default/bin:${PATH}
ENV LD_LIBRARY_PATH={install_prefix}/mpich-default/lib:${LD_LIBRARY_PATH:-}


USER ubuntu
WORKDIR ${workdir}
RUN << 'EOF'
wget https://raw.githubusercontent.com/PDC-support/introduction-to-pdc/master/example/hello_world_mpi.c
mpicc -fopenmp -o ./hello_world_mpi hello_world_mpi.c
./hello_world_mpi

EOF

