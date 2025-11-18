USER root
WORKDIR /tmp

RUN << 'EOF'

SCALAPACK_INCLUDES="${LIBSCALAPACK_INCLUDE_DIR:-/usr/include}"
SCALAPACK_LIBS="${LIBSCALAPACK_LIBS_DIR:-/usr/lib/x86_64-linux-gnu}"

OPENBLAS_INCLUDES="${LIBOPENBLAS_INCLUDE_DIR:-/usr/include}"
OPENBLAS_LIBS="${LIBOPENBLAS_LIBS_DIR:-/usr/lib/x86_64-linux-gnu}"

XC_INCLUDES="${LIBXC_INCLUDE_DIR:-/usr/include}"
XC_LIBS="${LIBXC_LIBS_DIR:-/usr/lib/x86_64-linux-gnu}"

VDWXC_INCLUDES="${LIBVDWXC_INCLUDE_DIR:-/usr/include}"
VDWXC_LIBS="${LIBVDWXC_LIBS_DIR:-/usr/lib/x86_64-linux-gnu}"

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


my_includes = [
    '${OPENBLAS_INCLUDES}',
    '${SCALAPACK_INCLUDES}',
    '${XC_INCLUDES}',
    '${VDWXC_INCLUDES}',
    '${FFTW_INCLUDES}'
]

my_libs = [
    '${OPENBLAS_LIBS}',
    '${SCALAPACK_LIBS}',
    '${XC_LIBS}',
    '${VDWXC_LIBS}',
    '${FFTW_LIBS}'
]

for minc in my_includes:
    if minc not in include_dirs:
        include_dirs += [minc]

for mlib in my_libs:
    if mlib not in library_dirs:
        library_dirs += [mlib]

    if mlib not in runtime_library_dirs:
        runtime_library_dirs += [mlib]

scalapack = True
#include_dirs += ['${SCALAPACK_INCLUDES}']
#library_dirs += ['${SCALAPACK_LIBS}']
#runtime_library_dirs += ['${SCALAPACK_LIBS}']
if 'scalapack' not in libraries:
    libraries += ['scalapack']

#include_dirs += ['${OPENBLAS_INCLUDES}']
#library_dirs += ['${OPENBLAS_LIBS}']
#runtime_library_dirs += ['${OPENBLAS_LIBS}']
if 'openblas' not in libraries:
    libraries += ['openblas']

if 1:
    libxc = True
#    include_dirs += ['${XC_INCLUDES}']
#    library_dirs += ['${XC_LIBS}']
    # You can use rpath to avoid changing LD_LIBRARY_PATH:
#    runtime_library_dirs += ['${XC_LIBS}']
    if 'xc' not in libraries:
        libraries += ['xc']

if 1:
    libvdwxc = True
#    library_dirs += ['${VDWXC_LIBS}']
#    include_dirs += ['${VDWXC_INCLUDES}']
#    runtime_library_dirs += ['${VDWXC_LIBS}']
    if 'vdwxc' not in libraries:
    	libraries += ['vdwxc']


if 1:
    fftw = True
#    library_dirs += ['${FFTW_LIBS}']
#    include_dirs += ['${FFTW_INCLUDES}']
#    runtime_library_dirs += ['${FFTW_LIBS}']
    if 'fftw3' not in libraries:
        libraries += ['fftw3']
#        libraries += ['fftw3_mpi']

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


