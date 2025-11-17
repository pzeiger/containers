USER root

# common/scalapack.dockerfile
RUN <<'EOF'
set -euxo pipefail

apt-get update
apt-get install -y \
    build-essential \
    gfortran \
    wget \
    cmake

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
    -DCMAKE_Fortran_COMPILER=mpif90 \
    -DCMAKE_C_COMPILER=mpicc \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_Fortran_FLAGS="{build_flags_f}" \
    -DCMAKE_C_FLAGS="{build_flags_c}" \
    -DBLAS_LIBRARIES="-L{install_prefix}/openblas-default/lib -lopenblas" \
    -DLAPACK_FOUND=ON

make -j{build_threads}
make install

ln -sf ${SCALAPACK_PREFIX} {install_prefix}/scalapack-default

cd /tmp
rm -rf scalapack-${SCALAPACK_VERSION}*

echo "✓ ScaLAPACK {version} built and installed"
EOF

