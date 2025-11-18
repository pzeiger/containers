USER root

RUN << 'EOF'

apt-get clean
rm -rf /var/lib/apt/lists/*
pip cache purge
rm -r /tmp

EOF

