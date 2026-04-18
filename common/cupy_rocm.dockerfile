USER root

# CuPy {version} for ROCm - GPU-accelerated NumPy-like array library
RUN <<'EOF'

# Set versions
CUPY_VERSION={version}
ROCM_VERSION=$(amd-smi version 2>/dev/null | grep -o 'ROCm version: [0-9.]\+' | cut -d' ' -f3 || true)
ROCM_VERSION=${ROCM_VERSION::-2}

echo $ROCM_VERSION
BUILD_FROM_SOURCE={build_from_source}
#BUILD_THREADS={build_threads}

if [ ${BUILD_FROM_SOURCE} -eq 1 ]; then
    # Build and install CuPy for HIP/ROCm
    export CUPY_INSTALL_USE_HIP=1
    export HCC_AMDGPU_TARGET={rocm_arch}
    export ROCM_HOME=/opt/rocm       # ROCm should already be installed
    
    # Install CuPy built for HIP/ROCm
    #MAKEFLAGS="-j$(BUILD_THREADS)" pip install -vv cupy==${CUPY_VERSION}
    pip install -vv cupy==${CUPY_VERSION}
else
#    pip install cupy-rocm-${ROCM_VERSION//./-}==${CUPY_VERSION}
    export ROCM_HOME=/opt/rocm       # ROCm should already be installed
    pip install fastrlock
    pip install amd-cupy --extra-index-url https://pypi.amd.com/rocm-7.2.0/simple
fi

echo "CuPy {version} for ROCm {rocm_version} installed successfully"
python3 -c "import cupy; print(f'CuPy version: {cupy.__version__}')"
#python3 -c "import cupy; print(f'Device: {cupy.cuda.Device()}')"
EOF

# 
#ENV LLVM_PATH="/opt/rocm/llvm"

ENV ROCM_HOME="/opt/rocm"
