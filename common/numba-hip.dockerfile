USER root

RUN <<'EOF'

ROCM_VERSION=$(amd-smi version 2>/dev/null | grep -o 'ROCm version: [0-9.]\+' | cut -d' ' -f3 || true)

pip-native config set global.extra-index-url https://test.pypi.org/simple 
pip-native install "numba-hip[rocm-${ROCM_VERSION//./-}] @ git+https://github.com/ROCm/numba-hip.git"

EOF

