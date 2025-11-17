USER root

RUN << 'EOF'

apt-get clean
rm -rf /var/lib/apt/lists/*
uv pip cache purge
pip cache purge
rm -r /tmp

EOF

