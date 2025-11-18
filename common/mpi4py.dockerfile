USER root

# common/mpi4py.dockerfile
RUN <<'EOF'

pip install mpi4py 

# Verify installation
python3 -c "import mpi4py; print(f'mpi4py {mpi4py.__version__} installed successfully')"

echo "✓ mpi4py built and installed from source"
EOF

