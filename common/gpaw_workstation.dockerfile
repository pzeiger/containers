USER root
WORKDIR /tmp

RUN << 'EOF'

SCALAPACK_INCLUDES="${LIBSCALAPACK_INCLUDE_DIR:-}"
SCALAPACK_LIBS="${LIBSCALAPACK_LIBS_DIR:-}"

OPENBLAS_INCLUDES="${LIBOPENBLAS_INCLUDE_DIR:-}"
OPENBLAS_LIBS="${LIBOPENBLAS_LIBS_DIR:-}"

XC_INCLUDES="${LIBXC_INCLUDE_DIR:-}"
XC_LIBS="${LIBXC_LIBS_DIR:-}"
VDWXC_INCLUDES="${LIBVDWXC_INCLUDE_DIR:-}"
VDWXC_LIBS="${LIBVDWXC_LIBS_DIR:-}"

FFTW_LIBS="${FFTW_DOUBLE_MPI_LIBS_DIR:-}"
FFTW_INCLUDES="${FFTW_DOUBLE_MPI_INCLUDE_DIR:-}"

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
include_dirs += ['${SCALAPACK_INCLUDES}']
library_dirs += ['${SCALAPACK_LIBS}']
runtime_library_dirs += ['${SCALAPACK_LIBS}']
if 'scalapack' not in libraries:
    libraries += ['scalapack']


include_dirs += ['${OPENBLAS_INCLUDES}']
library_dirs += ['${OPENBLAS_LIBS}']
runtime_library_dirs += ['${OPENBLAS_LIBS}']
if 'openblas' not in libraries:
    libraries += ['openblas']

if 1:
    libwxc = True
    include_dirs += ['${XC_INCLUDES}']
    library_dirs += ['${XC_LIBS}']
    # You can use rpath to avoid changing LD_LIBRARY_PATH:
    runtime_library_dirs += ['${XC_LIBS}']
    if 'xc' not in libraries:
        libraries.append('xc')

if 1:
    libvdwxc = True
    library_dirs += ['${VDWXC_LIBS}']
    include_dirs += ['${VDWXC_INCLUDES}']
    runtime_library_dirs += ['${VDWXC_LIBS}']
    libraries += ['vdwxc']


if 1:
    fftw = True
    library_dirs += ['${FFTW_LIBS}']
    include_dirs += ['${FFTW_INCLUDES}']
    runtime_library_dirs += ['${FFTW_LIBS}']
    if 'fftw3' not in libraries:
        libraries += ['fftw3']
        libraries += ['fftw3_mpi']

# hip
if 0:
    gpu = True
    gpu_target = 'hip-amd'
    gpu_compiler = 'hipcc'
    gpu_include_dirs = ['/opt/rocm/include']
    gpu_library_dirs = ['/opt/rocm/lib']
    gpu_compile_args = [
        '-g',
        '-O3',
        '--offload-arch=${ROCM_ARCH}',
       ]
    libraries += ['amdhip64', 'hipblas']


#blacs = True
#if 'blacs' not in libraries:
#    libraries += ['blacs']
    
INNER_EOF

pip-native install --break-system-packages gpaw #--verbose

EOF



#USER ubuntu
#WORKDIR /home/ubuntu
#
#RUN << 'EOF'
#ldd /usr/local/lib/python3.12/dist-packages/_gpaw.cpython-312-x86_64-linux-gnu.so
#gpaw info
#gpaw test
#gpaw -P 4 test
#
#
#
#EOF


