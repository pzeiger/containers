USER root
RUN << 'EOF'

TORCH_VERSION={version}
ROCM_VERSION={rocm_version}
ROCM_VERSION=$(echo "${ROCM_VERSION}" | awk -F '.' '{print $1"."$2}')

pip install torch==${TORCH_VERSION} --index-url https://download.pytorch.org/whl/rocm${ROCM_VERSION}

EOF

