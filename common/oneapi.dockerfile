USER root
RUN <<'EOF'

curl -Lo- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null
sudo tee /etc/apt/sources.list.d/oneAPI.list <<< "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main"
sudo apt update

apt-get install intel-oneapi-compiler-fortran intel-oneapi-mkl

EOF

USER ubuntu
RUN echo "source /opt/intel/oneapi/setvars.sh > /dev/null" >> ~/.bashrc

