USER root

RUN << 'EOF'
git clone https://github.com/abTEM/abTEM.git
cd abTEM
git checkout pmz-mods
pip install .[testing,dev]
pip install xarray
cd ..
rm -r abTEM
touch /dev/null
EOF


