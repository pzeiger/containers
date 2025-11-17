USER root

RUN << 'EOF'
git clone https://github.com/abTEM/abTEM.git
cd abTEM
pip install .
EOF


