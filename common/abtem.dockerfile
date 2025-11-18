USER root

RUN << 'EOF'
git clone https://github.com/abTEM/abTEM.git
cd abTEM
pip install .
cd ..
rm -r abTEM
EOF


