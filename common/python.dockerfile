# Copy uv into image
USER root

# common/uv_python.dockerfile
RUN <<'EOF'
set -euxo pipefail

apt-get update
apt-get install \
    python3 \
    python3-dev \
    python3-pip \
    build-essential

# Install uv
pip3 install --break-system-packages uv

# Save original pip as pip-native
cp /usr/bin/pip /usr/bin/pip-native
cp /usr/bin/pip3 /usr/bin/pip3-native

# Create pip wrapper that only redirects "install" command
cat > /usr/local/bin/pip <<'PIP_WRAPPER'
#!/bin/bash
# Reroute only "pip install" to uv, everything else to native pip

if [ "$1" = "install" ]; then
    # Redirect install to uv (remove "install" argument since uv pip already has it)
    shift  # Remove "install" from arguments
    exec uv pip install --system --no-cache-dir "$@"
else
    # Pass all other commands to native pip
    exec /usr/bin/pip-native "$@"
fi
PIP_WRAPPER

chmod +x /usr/local/bin/pip

# Create pip3 wrapper (same logic)
cat > /usr/local/bin/pip3 <<'PIP3_WRAPPER'
#!/bin/bash
# Reroute only "pip3 install" to uv, everything else to native pip3

if [ "$1" = "install" ]; then
    # Redirect install to uv
    shift
    exec uv pip install --system --no-cache-dir "$@"
else
    # Pass all other commands to native pip
    exec /usr/bin/pip3-native "$@"
fi
PIP3_WRAPPER

chmod +x /usr/local/bin/pip3


# Set Python as default
ln -sf /usr/bin/python3 /usr/bin/python

echo "✓ Python environment ready"
uv --version
python --version

pip install -U setuptools wheel
EOF

