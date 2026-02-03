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
    ipympl \
    mp_api \
    orb-models \
    pytest

touch /dev/null
#    fairchem-core \

EOF

ENV FAIRCHEM_CACHE_DIR={data_prefix}/potentials

