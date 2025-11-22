USER root
RUN << 'EOF'
pip install \
    phonopy \
    seekpath \
    pymatgen \
    wannierberri \
    calorine \
    dynasor \
    hiphive \
    ipython \
    ipympl

EOF

