USER root

# ScaLAPACK {version} module - Distributed linear algebra
RUN <<'EOF' bash
set -euxo pipefail

# Install dependencies
apt-get update
apt-get install \
    build-essential \
    gfortran \
    wget

# Set paths
SCALAPACK_PREFIX={install_prefix}/scalapack-{version}
SCALAPACK_VERSION={version}
OPENBLAS_PREFIX={install_prefix}/openblas-default

# Download
cd /tmp
wget http://www.netlib.org/scalapack/scalapack-${SCALAPACK_VERSION}.tgz
tar xf scalapack-${SCALAPACK_VERSION}.tgz
cd scalapack-${SCALAPACK_VERSION}

# Create SLmake.inc for ScaLAPACK
cat > SLmake.inc <<'SCALAPACK_CONF'
CDEFS         = -DAdd_
FC            = mpif90
CC            = mpicc
FCFLAGS       = -O3 -march=native
CCFLAGS       = -O3 -march=native
FCLOADER      = mpif90
CCLOADER      = mpicc
FCLOADFLAGS   = -O3 -march=native
CCLOADFLAGS   = -O3 -march=native

BLASLIB       = -L{install_prefix}/openblas-default/lib -lopenblas
LAPACKLIB     = 

LIBS          = $(LAPACKLIB) $(BLASLIB)

SCALAPACK_VERSION = {version}
SCALAPACK_CONF

# Build
make -j{build_threads}

# Install
mkdir -p ${SCALAPACK_PREFIX}/lib
cp libscalapack.a ${SCALAPACK_PREFIX}/lib/
mkdir -p ${SCALAPACK_PREFIX}/include

# Create symlink
ln -sf ${SCALAPACK_PREFIX} {install_prefix}/scalapack-default

# Cleanup
cd /tmp
rm -rf scalapack-${SCALAPACK_VERSION}*

echo "ScaLAPACK {version} installed successfully"
EOF

USER ubuntu
