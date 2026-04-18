USER root
RUN << 'EOF'

pip list

pip install \
    phonopy\<=2.45.1 \
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
    scikit-image

#    fairchem-core \


pip install git+https://github.com/h-walk/PySlice.git@py3.11

pip install --no-build-isolation dynaphopy
#    git+https://github.com/pzeiger/DynaPhoPy.git


EOF

ENV FAIRCHEM_CACHE_DIR={data_prefix}/potentials
ENV ORBV3_CACHE_DIR=/opt/data/potentials/ORBv3

