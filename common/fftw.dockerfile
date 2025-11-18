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

#export CFLAGS="{build_flags_c}"
#export FFLAGS="{build_flags_f}"

# Build 3: Double precision with MPI
./configure ${COMMON_FLAGS} ${FLAGS_DOUBLE} --enable-mpi \
   --prefix=${FFTW_PREFIX}
make -j{build_threads}
make install
make clean

# Build 4: Single precision with MPI
./configure ${COMMON_FLAGS} ${FLAGS_SINGLE} --enable-mpi \
   --prefix=${FFTW_PREFIX}
make -j{build_threads}
make install
make clean

ln -sf ${FFTW_PREFIX} {install_prefix}/fftw-default

# Cleanup
cd /tmp
rm -rf fftw-${FFTW_VERSION}*

echo "FFTW {version} installed successfully"
EOF

ENV FFTW_HOME={install_prefix}/fftw-default
ENV FFTW_INCLUDE_DIR=${FFTW_HOME}/include
ENV FFTW_LIBS_DIR=${FFTW_HOME}/lib

ENV LD_LIBRARY_PATH=${FFTW_LIBS_DIR}:${LD_LIBRARY_PATH:-}

# For Fortran code
ENV FFTW_INCLUDE_DIR=${FFTW_HOME}/include
ENV FFTW_LIB_DIR=${FFTW_HOME}/lib

