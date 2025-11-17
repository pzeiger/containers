# common/lammps.dockerfile
RUN <<'EOF' bash
set -euxo pipefail

# Install build dependencies
apt-get update
apt-get install -y \
    build-essential \
    cmake \
    git \
    mpi-default-bin \
    mpi-default-dev \
    libfftw3-dev \
    libjpeg-dev \
    libpng-dev \
    libyaml-dev \
    python3-dev \
    python3-pip \
    python3-numpy

# Upgrade pip and install Python modules
python3 -m pip install --upgrade pip setuptools numpy

# Set LAMMPS version
LAMMPS_VERSION=stable_29Sep2023

# Clone LAMMPS repo
cd /tmp
rm -rf lammps
git clone --depth 1 --branch ${LAMMPS_VERSION} https://github.com/lammps/lammps.git
cd lammps

# Create build directory
mkdir -p build
cd build

# Configure with MPI, FFTW, Python packages & common packages
cmake .. \
    -D BUILD_MPI=ON \
    -D BUILD_SHARED_LIBS=ON \
    -D BUILD_PYTHON_MODULE=ON \
    -D PYTHON_EXECUTABLE=$(which python3) \
    -D FFT=FFTW3 \
    -D PKG_MOLECULE=ON \
    -D PKG_KSPACE=ON \
    -D PKG_MANYBODY=ON \
    -D PKG_USER-REAXC=ON \
    -D PKG_USER-MOLFILE=ON \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=/opt/software/lammps-${LAMMPS_VERSION}

# Build and install
make -j$(nproc)
make install

# Install Python package wrapper
cd ../python
python3 setup.py install --prefix=/opt/software/lammps-${LAMMPS_VERSION}

# Create symlink for easier access
ln -sf /opt/software/lammps-${LAMMPS_VERSION} /opt/software/lammps-default

echo "✓ LAMMPS ${LAMMPS_VERSION} built and installed successfully"
EOF

