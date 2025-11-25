USER root

RUN << 'EOF'
git clone https://github.com/abTEM/abTEM.git
cd abTEM
pip install .
pip install xarray
cd ..
rm -r abTEM
EOF


