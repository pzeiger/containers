# CuPy {version} with ROCm - GPU-accelerated NumPy-like array library
RUN <<'EOF'
set -euxo pipefail

# Install dependencies
apt-get update
apt-get install -y \
    build-essential \
    python3-dev \
    wget

# Set versions
CUPY_VERSION={version}
ROCM_PATH=/opt/rocm  # ROCm should already be installed

# Install CuPy with ROCm support via pip
export HCC_HOME=${ROCM_PATH}
export ROCM_HOME=${ROCM_PATH}
export PATH=${ROCM_PATH}/bin:${PATH}

# Install CuPy built for HIP/ROCm
pip install cupy-hip>={CUPY_VERSION}

echo "CuPy {version} with ROCm installed successfully"
python3 -c "import cupy; print(f'CuPy version: {cupy.__version__}')"
python3 -c "import cupy; print(f'Device: {cupy.cuda.Device()}')"
EOF


