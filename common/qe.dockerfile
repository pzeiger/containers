USER root
WORKDIR /tmp


RUN << 'EOF'

QE_VERSION="{version}"
QE_INSTALL_PREFIX="{install_prefix}/qe-${QE_VERSION}"
#QE_DATA_PREFIX="{data_prefix}/qe-${QE_VERSION}"

wget https://gitlab.com/QEF/q-e/-/archive/qe-${QE_VERSION}/q-e-qe-${QE_VERSION}.tar.gz
tar xzf q-e-qe-${QE_VERSION}.tar.gz

cd q-e-qe-${QE_VERSION}

SCALAPACK_INCLUDES="${LIBSCALAPACK_INCLUDE_DIR:-/usr/include}"
SCALAPACK_LIBS="${LIBSCALAPACK_LIBS_DIR:-/usr/lib/x86_64-linux-gnu}"

OPENBLAS_INCLUDES="${LIBOPENBLAS_INCLUDE_DIR:-/usr/include}"
OPENBLAS_LIBS="${LIBOPENBLAS_LIBS_DIR:-/usr/lib/x86_64-linux-gnu}"

ROCM_ARCH={rocm_arch}
BIN_DIR={bin_dir}

LIBXCROOT="${LIBXC_HOME}" 

##./configure LIBDIRS="${LIBSCALAPACK_LIBS_DIR:-/usr/lib/x86_64-linux-gnu} ${LIBOPENBLAS_LIBS_DIR:-/usr/lib/x86_64-linux-gnu}" CFLAGS="-fPIC" FFLAGS="-fPIC"
#./configure \
#  --prefix="${QE_INSTALL_PREFIX}" \
#  --enable-openmp yes \
#  --enable-pedantic yes \
#  --enable-exit-status yes \
#  --with-hdf5 yes \
#  --with-libxc yes --with-libxc-prefix=${SCALAPACK_LIBS} --with-libxc-include=${SCALAPACK_INCLUDES} \
#  --with-scalapack yes --with-scalapack-qrcp yes \

mkdir ./build
cd ./build
echo "${SCALAPACK_LIBS}"
#ls -ahl "${SCALAPACK_LIBS}/libscala*"
cmake -DCMAKE_Fortran_COMPILER=mpif90 \
      -DCMAKE_C_COMPILER=mpicc \
      -DCMAKE_C_FLAGS="-fPIC {build_flags_c}" \
      -DCMAKE_Fortran_FLAGS="-fPIC {build_flags_f}" \
      -DCMAKE_PREFIX_PATH="${SCALAPACK_LIBS} ${OPENBLAS_LIBS}" \
      -DCMAKE_INSTALL_PREFIX="${QE_INSTALL_PREFIX}" \
      -DQE_ENABLE_OPENMP="ON" \
      -DQE_GPU="openmp;rocm" \
      -DQE_GPU_ARCHS="${ROCM_ARCH}" \
      -DQE_ENABLE_HDF5="ON" \
      ..

#      -DQE_ENABLE_LIBXC="ON" \
#      -DLIBXC_ROOT="${LIBXC_HOME}" \
#      -DLibxc_ROOT="${LIBXC_HOME}" \
#      -DQE_ENABLE_SCALAPACK="ON" \
#      -DSCALAPACK_LIBDIR="${SCALAPACK_LIBS}" \
#      -DSCALAPACK_INCDIR="${SCALAPACK_INCLUDES}" \

make -j {build_threads}
make install

ls -ahl "/opt/"
ls -ahl "/opt/bin"
for fname in ${QE_INSTALL_PREFIX}/bin/*;
do
    exe=$(basename ${fname})
    ln -s "${fname}" "${BIN_DIR}/${exe}"
done

#
#OPENBLAS_INCLUDES="${LIBOPENBLAS_INCLUDE_DIR:-/usr/include}"
#OPENBLAS_LIBS="${LIBOPENBLAS_LIBS_DIR:-/usr/lib/x86_64-linux-gnu}"
#
#XC_INCLUDES="${LIBXC_INCLUDE_DIR:-/usr/include}"
#XC_LIBS="${LIBXC_LIBS_DIR:-/usr/lib/x86_64-linux-gnu}"
#
#VDWXC_INCLUDES="${LIBVDWXC_INCLUDE_DIR:-/usr/include}"
#VDWXC_LIBS="${LIBVDWXC_LIBS_DIR:-/usr/lib/x86_64-linux-gnu}"
#
#FFTW_LIBS="${FFTW_DOUBLE_MPI_LIBS_DIR:-/usr/include}"
#FFTW_INCLUDES="${FFTW_DOUBLE_MPI_INCLUDE_DIR:-/usr/lib/x86_64-linux-gnu}"
#
#GPAW_VERSION="{version}"
#GPAW_PREFIX="{install_prefix}/gpaw-{version}"
#GPAW_CONFIG_DIR="{install_prefix}/.gpaw"
#export GPAW_CONFIG="${GPAW_CONFIG_DIR}/siteconfig.py"
#
#ROCM_ARCH={rocm_arch}
#
#mkdir -p ${GPAW_CONFIG_DIR}
#
#cp -a ${GPAW_CONFIG} /home/ubuntu/.gpaw
#chown -R ubuntu:ubuntu /home/ubuntu/.gpaw
#
#pip install gpaw #--verbose
#pip install "git+https://github.com/pzeiger/gpaw-weaver.git"

EOF



USER ubuntu
WORKDIR ${WORKDIR}

RUN << 'EOF'



EOF


