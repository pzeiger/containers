USER root

# common/scalapack.dockerfile
RUN <<'EOF'

SCALAPACK_PREFIX={install_prefix}/scalapack-{version}
SCALAPACK_VERSION={version}

cd /tmp
wget https://github.com/Reference-ScaLAPACK/scalapack/archive/refs/tags/v${SCALAPACK_VERSION}.tar.gz
tar xf v${SCALAPACK_VERSION}.tar.gz
cd scalapack-${SCALAPACK_VERSION}

mkdir build
cd build

# CMake build is more robust
cmake .. \
    -DCMAKE_INSTALL_PREFIX=${SCALAPACK_PREFIX} \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DCMAKE_Fortran_COMPILER=mpif90 \
    -DCMAKE_C_COMPILER=mpicc \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_Fortran_FLAGS="{build_flags_f} -fPIC" \
    -DCMAKE_C_FLAGS="{build_flags_c} -fPIC" \
    -DBLAS_LIBRARIES="-L${LIBOPENBLAS_LIBS_DIR} -lopenblas"

cmake --build . -j{build_threads} --verbose
make install

ln -sf ${SCALAPACK_PREFIX} {install_prefix}/scalapack-default

cd /tmp
rm -rf scalapack-${SCALAPACK_VERSION}*

echo "✓ ScaLAPACK {version} built and installed"
EOF

ENV LIBSCALAPACK_HOME={install_prefix}/scalapack-default
ENV LIBSCALAPACK_LIBS_DIR=${LIBSCALAPACK_HOME}/lib
ENV LIBSCALAPACK_INCLUDE_DIR=${LIBSCALAPACK_HOME}/include
