# Set default behavior of shell
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
ENV DEBIAN_FRONTEND="noninteractive"
USER root

# Base development tools module
RUN <<'EOF'

mkdir -p {install_prefix}

# Create APT configuration
cat > /etc/apt/apt.conf.d/99custom <<'APT_CONF'
APT::Get::Assume-Yes "true";
APT_CONF

# Update and install
apt-get update
apt-get full-upgrade
apt-get install \
    autoconf \
    automake \
    build-essential \
    cmake \
    gfortran \
    git \
    libtool \
    wget \
    mpi-default-dev \
    libopenblas-dev \
    liblapack-dev \
    libfftw3-dev \
    libfftw3-mpi-dev \
    libscalapack-mpi-dev \
    libhdf5-dev \
    python3-tk


## Create environment paths script
#cat > {install_prefix}/environment.sh <<'ENVIRONMENT'
## Add compiled software to standard paths
#export LD_LIBRARY_PATH=/opt/software/*/lib:/opt/software/*/*/lib:${LD_LIBRARY_PATH:-}
#export PATH=/opt/software/*/bin:/opt/software/*/*/bin:${PATH}
#export PKG_CONFIG_PATH=/opt/software/*/lib/pkgconfig:/opt/software/*/*/lib/pkgconfig:${PKG_CONFIG_PATH}
#export CPATH=/opt/software/*/include:/opt/software/*/*/include:${CPATH}
#ENVIRONMENT
#
#chmod 644 {install_prefix}/environment.sh
#
#echo "source {install_prefix}/environment.sh" >> /etc/bash.bashrc

EOF

