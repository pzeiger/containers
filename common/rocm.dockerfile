USER root
RUN usermod -a -G video ubuntu # Add the current user to the video group

ENV ROCM_VERSION={version}

#RUN <<'EOF'
#
## Make the directory if it doesn't exist yet.
## This location is recommended by the distribution maintainers.
#mkdir --parents --mode=0755 /etc/apt/keyrings
#
#. /etc/os-release
#read _ UBUNTU_VERSION_NAME <<< "$VERSION"
#echo "$UBUNTU_VERSION_NAME"
#UBUNTU_VERSION_NAME=${UBUNTU_VERSION_NAME//[()]/}
#UBUNTU_VERSION_NAME=(${UBUNTU_VERSION_NAME})
#UBUNTU_VERSION_NAME=${UBUNTU_VERSION_NAME[1]}
#UBUNTU_VERSION_NAME=${UBUNTU_VERSION_NAME,,}
#echo "$UBUNTU_VERSION_NAME"
#
#
## Download the key, convert the signing-key to a full
## keyring required by apt and store in the keyring directory
#wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | \
#gpg --dearmor | tee /etc/apt/keyrings/rocm.gpg > /dev/null
#
#tee --append /etc/apt/sources.list.d/rocm.list << INNER_EOF
#deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/$ROCM_VERSION $UBUNTU_VERSION_NAME main
#INNER_EOF
#
#
#tee /etc/apt/preferences.d/rocm-pin-600 << INNER_EOF
#Package: *
#Pin: release o=repo.radeon.com
#Pin-Priority: 600
#INNER_EOF
#
#apt-get update
#apt-get install rocm$ROCM_VERSION
#EOF


RUN <<'EOF'
. /etc/os-release
read _ UBUNTU_VERSION_NAME <<< "$VERSION"
echo "$UBUNTU_VERSION_NAME"
UBUNTU_VERSION_NAME=${UBUNTU_VERSION_NAME//[()]/}
UBUNTU_VERSION_NAME=(${UBUNTU_VERSION_NAME})
UBUNTU_VERSION_NAME=${UBUNTU_VERSION_NAME[1]}
UBUNTU_VERSION_NAME=${UBUNTU_VERSION_NAME,,}
echo "$UBUNTU_VERSION_NAME"


rocm_to_package_version() {
    local rocm_version="$1"
    local major minor patch
    
    # Parse version components
    IFS='.' read -r major minor patch <<< "$rocm_version"
    
    # Handle missing patch version (treat as .0)
    patch=${patch:-0}
    
    # Encode to package format: XXYYZZ
    local encoded=$(printf "%d%02d%02d" "$major" "$minor" "$patch")
    
    echo "${major}.${minor}.${encoded}-1"
}

ROCM_PACKAGE_VERSION=$(rocm_to_package_version $ROCM_VERSION)
echo $ROCM_PACKAGE_VERSION


wget https://repo.radeon.com/amdgpu-install/{version}/ubuntu/${UBUNTU_VERSION_NAME}/amdgpu-install_${ROCM_PACKAGE_VERSION}_all.deb
apt-get install ./amdgpu-install_${ROCM_PACKAGE_VERSION}_all.deb
apt-get update
#apt-get install python3-setuptools python3-wheel
apt-get install rocm

groupadd -r render || true
usermod -a -G render,video ubuntu

# Compiling a GPU test application
wget https://raw.githubusercontent.com/PDC-support/introduction-to-pdc/master/example/hello_world_gpu.cpp
hipcc --offload-arch=gfx90a -o /usr/local/bin/hello_world_gpu hello_world_gpu.cpp

EOF


USER ubuntu


