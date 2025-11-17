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
COMMON_FLAGS="--enable-shared --enable-threads --enable-sse2 --enable-avx --enable-avx2 --enable-avx512 --enable-avx-128-fma --enable-generic-simd128 --enable-generic-simd256"
FLAGS_SINGLE="--enable-float"
FLAGS_DOUBLE=""

BUILD_FLAGS_C="{build_flags_c}"
BUILD_FLAGS_F="{build_flags_f}"


# Build 1: Double precision without MPI
./configure ${COMMON_FLAGS} ${FLAGS_DOUBLE} \
   --prefix=${FFTW_PREFIX}/double \
   CFLAGS="${BUILD_FLAGS_C}" \
   FFLAGS="${BUILD_FLAGS_F}"
make -j{build_threads}
make install
make clean

# Build 2: Single precision without MPI
./configure ${COMMON_FLAGS} ${FLAGS_SINGLE} \
   --prefix=${FFTW_PREFIX}/single \
   CFLAGS="${BUILD_FLAGS_C}" \
   FFLAGS="${BUILD_FLAGS_F}"
make -j{build_threads}
make install
make clean

# Build 3: Double precision with MPI
./configure ${COMMON_FLAGS} ${FLAGS_DOUBLE} --enable-mpi \
   --prefix=${FFTW_PREFIX}/double-mpi \
   CFLAGS="${BUILD_FLAGS_C}" \
   FFLAGS="${BUILD_FLAGS_F}"
make -j{build_threads}
make install
make clean

# Build 4: Single precision with MPI
./configure ${COMMON_FLAGS} ${FLAGS_SINGLE} --enable-mpi \
   --prefix=${FFTW_PREFIX}/single-mpi \
   CFLAGS="${BUILD_FLAGS_C}" \
   FFLAGS="${BUILD_FLAGS_F}"
make -j{build_threads}
make install
make clean

ln -sf ${FFTW_PREFIX} {install_prefix}/fftw-default

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

ENV FFTW_HOME={install_prefix}/fftw-default
ENV FFTW_DOUBLE_DIR=${FFTW_HOME}/double
ENV FFTW_SINGLE_DIR=${FFTW_HOME}/single
ENV FFTW_DOUBLE_MPI_DIR=${FFTW_HOME}/double-mpi
ENV FFTW_SINGLE_MPI_DIR=${FFTW_HOME}/single-mpi

ENV FFTW_DOUBLE_INCLUDE_DIR=${FFTW_DOUBLE_DIR}/include
ENV FFTW_SINGLE_INCLUDE_DIR=${FFTW_SINGLE_DIR}/include
ENV FFTW_DOUBLE_MPI_INCLUDE_DIR=${FFTW_DOUBLE_MPI_DIR}/include
ENV FFTW_SINGLE_MPI_INCLUDE_DIR=${FFTW_SINGLE_MPI_DIR}/include

ENV FFTW_DOUBLE_LIBS_DIR=${FFTW_DOUBLE_DIR}/lib
ENV FFTW_SINGLE_LIBS_DIR=${FFTW_SINGLE_DIR}/lib
ENV FFTW_DOUBLE_MPI_LIBS_DIR=${FFTW_DOUBLE_MPI_DIR}/lib
ENV FFTW_SINGLE_MPI_LIBS_DIR=${FFTW_SINGLE_MPI_DIR}/lib

# For Fortran code
ENV FFTW_INCLUDE_DIR=${FFTW_DOUBLE_DIR}/include
ENV FFTW_LIB_DIR=${FFTW_DOUBLE_DIR}/lib

