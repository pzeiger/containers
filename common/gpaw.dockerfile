USER root
WORKDIR /tmp

RUN << 'EOF'

ls ${LIBXC_LIBS_DIR}
ls ${LIBXC_INCLUDE_DIR}
ls ${LIBVDWXC_LIBS_DIR}
ls ${LIBVDWXC_INCLUDE_DIR}

GPAW_VERSION="{version}"
GPAW_PREFIX="{install_prefix}/gpaw-{version}"
GPAW_CONFIG_DIR="{install_prefix}/.gpaw"
export GPAW_CONFIG="${GPAW_CONFIG_DIR}/siteconfig.py"

ROCM_ARCH={rocm_arch}

mkdir -p ${GPAW_CONFIG_DIR}

tee ${GPAW_CONFIG} << INNER_EOF


mpi = True
if mpi:
    compiler = 'mpicc'

if '-fopenmp' not in extra_compile_args:
    extra_compile_args += ['-fopenmp']

if '-fopenmp' not in extra_link_args:
    extra_link_args += ['-fopenmp']

print(extra_compile_args)
print(extra_link_args)

#extra_compile_args += ['{build_flags_c}']
#extra_link_args += ['{build_flags_c}']

scalapack = True
include_dirs += ['${LIBSCALAPACK_INCLUDE_DIR}']
library_dirs += ['${LIBSCALAPACK_LIBS_DIR}']
runtime_library_dirs += ['${LIBSCALAPACK_LIBS_DIR}']
if 'scalapack' not in libraries:
    libraries += ['scalapack']


include_dirs += ['${LIBOPENBLAS_INCLUDE_DIR}']
library_dirs += ['${LIBOPENBLAS_LIBS_DIR}']
runtime_library_dirs += ['${LIBOPENBLAS_LIBS_DIR}']
if 'openblas' not in libraries:
    libraries += ['openblas']

if 1:
    libwxc = True
    include_dirs += ['${LIBXC_INCLUDE_DIR}']
    library_dirs += ['${LIBXC_LIBS_DIR}']
    # You can use rpath to avoid changing LD_LIBRARY_PATH:
    runtime_library_dirs += ['${LIBXC_LIBS_DIR}']
    
    if 'xc' not in libraries:
        libraries.append('xc')

if 1:
    libvdwxc = True
    library_dirs += ['${LIBVDWXC_LIBS_DIR}']
    include_dirs += ['${LIBVDWXC_INCLUDE_DIR}']
    runtime_library_dirs += ['${LIBVDWXC_INCLUDE_DIR}']
    libraries += ['vdwxc']


if 1:
    fftw = True
    library_dirs += ['${FFTW_DOUBLE_MPI_LIBS_DIR}']
    include_dirs += ['${FFTW_DOUBLE_MPI_INCLUDE_DIR}']
    runtime_library_dirs += ['${FFTW_DOUBLE_MPI_LIBS_DIR}']
    if 'fftw3' not in libraries:
        libraries += ['fftw3']
        libraries += ['fftw3_mpi']

# hip
#gpu = True
#gpu_target = 'hip-amd'
#gpu_compiler = 'hipcc'
#gpu_include_dirs = ['/opt/rocm/include']
#gpu_library_dirs = ['/opt/rocm/lib']
#gpu_compile_args = [
#    '-g',
#    '-O3',
#    '--offload-arch=${ROCM_ARCH}',
#    ]
#libraries += ['amdhip64', 'hipblas']


#blacs = True
#if 'blacs' not in libraries:
#    libraries += ['blacs']
    
#runtime_library_dirs += ['/usr/lib64/mpi/gcc/openmpi4/lib64', '/usr/lib64']
#library_dirs += ['/usr/lib64/mpi/gcc/openmpi5/lib64', '/usr/lib64']
#extra_link_args += ['/usr/lib64/mpi/gcc/openmpi5/lib64', '/usr/lib64']

INNER_EOF

pip-native install --break-system-packages gpaw #--verbose

EOF

USER ubuntu
WORKDIR /home/ubuntu

RUN << 'EOF'

gpaw info
gpaw test
gpaw -P 4 test



EOF


