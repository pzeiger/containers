# FFTW {version} module - Compiled for MPI and single/double precision with optimizations
USER root
RUN <<'EOF'

# Set installation prefix
FFTW_PREFIX={install_prefix}/fftw-{version}
FFTW_VERSION={version}

# Download FFTW source
cd /tmp
wget http://www.fftw.org/fftw-${FFTW_VERSION}.tar.gz
tar xf fftw-${FFTW_VERSION}.tar.gz
cd fftw-${FFTW_VERSION}

# Common configure flags for optimization
COMMON_FLAGS="--enable-shared --enable-threads --enable-sse2 --enable-avx --enable-avx2 --enable-avx512 --enable-avx-128-fma --enable-kcvi --enable-altivec --enable-vsx --enable-generic-simd128 --enable-generic-simd256"
FLAGS_SINGLE="--enable-float --enable-sse --enable-kcvi --enable-altivec"
FLAGS_DOUBLE=""

# Build 1: Double precision without MPI
./configure ${COMMON_FLAGS} ${FLAGS_DOUBLE} --prefix=${FFTW_PREFIX}/double
make -j{build_threads}
make install
make clean

# Build 2: Single precision without MPI
./configure ${COMMON_FLAGS} ${FLAGS_SINGLE} --prefix=${FFTW_PREFIX}/single
make -j{build_threads}
make install
make clean

# Build 3: Double precision with MPI
./configure ${COMMON_FLAGS} ${FLAGS_DOUBLE} --enable-mpi --prefix=${FFTW_PREFIX}/double-mpi
make -j{build_threads}
make install
make clean

# Build 4: Single precision with MPI
./configure ${COMMON_FLAGS} ${FLAGS_SINGLE} --enable-mpi --prefix=${FFTW_PREFIX}/single-mpi
make -j{build_threads}
make install
make clean

cat > /etc/profile.d/fftw.sh << 'SOFTWARE_PATHS'
export FFTW_HOME=/opt/software/fftw-3.3.10
export FFTW_DOUBLE_DIR=${FFTW_HOME}/double
export FFTW_SINGLE_DIR=${FFTW_HOME}/single
export FFTW_DOUBLE_MPI_DIR=${FFTW_HOME}/double-mpi
export FFTW_SINGLE_MPI_DIR=${FFTW_HOME}/single-mpi

# For Fortran code
export FFTW_INCLUDE_DIR=${FFTW_DOUBLE_DIR}/include
export FFTW_LIB_DIR=${FFTW_DOUBLE_DIR}/lib
SOFTWARE_PATHS

chmod 644 /etc/profile.d/fftw.sh

# Cleanup
cd /tmp
rm -rf fftw-${FFTW_VERSION}*

echo "FFTW {version} installed successfully"
echo "Installed variants:"
echo "  - ${FFTW_PREFIX}/double (double precision, no MPI)"
echo "  - ${FFTW_PREFIX}/single (single precision, no MPI)"
echo "  - ${FFTW_PREFIX}/double-mpi (double precision, MPI)"
echo "  - ${FFTW_PREFIX}/single-mpi (single precision, MPI)"
EOF

