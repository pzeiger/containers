USER root

# CuPy {version} with ROCm - GPU-accelerated NumPy-like array library
RUN <<'EOF'

# Install dependencies
apt-get update
apt-get install -y \
    build-essential \
    python3-dev \
    wget

# Set versions
CUPY_VERSION={version}

# Install CuPy with ROCm support via pip
export CUPY_INSTALL_USE_HIP=1
export HCC_AMDGPU_TARGET={rocm_arch}
export ROCM_HOME=/opt/rocm  # ROCm should already be installed

# Install CuPy built for HIP/ROCm
pip install cupy>={CUPY_VERSION}

echo "CuPy {version} with ROCm installed successfully"
python3 -c "import cupy; print(f'CuPy version: {cupy.__version__}')"
#python3 -c "import cupy; print(f'Device: {cupy.cuda.Device()}')"
EOF


