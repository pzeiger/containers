USER root

# CuPy {version} for ROCm - GPU-accelerated NumPy-like array library
RUN <<'EOF'

# Set versions

ROCM_VERSION=$(amd-smi version 2>/dev/null | grep -o 'ROCm version: [0-9.]\+' | cut -d' ' -f3 || true)

echo $ROCM_VERSION
CUPY_VERSION={version}
BUILD_FROM_SOURCE={build_from_source}

if [ ${BUILD_FROM_SOURCE} -eq 1 ]; then
    # Build and install CuPy for HIP/ROCm
    export CUPY_INSTALL_USE_HIP=1
    export HCC_AMDGPU_TARGET={rocm_arch}
    export ROCM_HOME=/opt/rocm       # ROCm should already be installed
    
    pip install -vvv --pre -f https://pip.cupy.dev/pre cupy==${CUPY_VERSION}
else
    # Install CuPy with ROCm support via pip
    pip install -vvv --pre -f https://pip.cupy.dev/pre cupy-rocm-${ROCM_VERSION//./-}
fi

echo "CuPy {version} for ROCm {rocm_version} installed successfully"
python3 -c "import cupy; print(f'CuPy version: {cupy.__version__}')"
#python3 -c "import cupy; print(f'Device: {cupy.cuda.Device()}')"
EOF

