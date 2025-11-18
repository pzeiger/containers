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

FFTW_LIBS="${FFTW_DOUBLE_MPI_LIBS_DIR:-/usr/include}"
FFTW_INCLUDES="${FFTW_DOUBLE_MPI_INCLUDE_DIR:-/usr/lib/x86_64-linux-gnu}"

GPAW_VERSION="{version}"
GPAW_PREFIX="{install_prefix}/gpaw-{version}"
GPAW_CONFIG_DIR="{install_prefix}/.gpaw"
export GPAW_CONFIG="${GPAW_CONFIG_DIR}/siteconfig.py"

ROCM_ARCH={rocm_arch}

mkdir -p ${GPAW_CONFIG_DIR}

tee ${GPAW_CONFIG} << INNER_EOF

from pathlib import Path

mpi = True
if mpi:
    compiler = 'mpicc'

if '-fopenmp' not in extra_compile_args:
    extra_compile_args += ['-fopenmp']

if '-fopenmp' not in extra_link_args:
    extra_link_args += ['-fopenmp']

print(extra_compile_args)
print(extra_link_args)

build_flags = '{build_flags_c}'

for x in build_flags.strip(' ').split('-')[1:]:
    flag = '-' + x.strip()
    extra_compile_args += [flag]
    extra_link_args += [flag]

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
    if minc not in include_dirs and minc != '':
        include_dirs += [minc]

for mlib in my_libs:
    if mlib not in library_dirs and mlib != '':
        library_dirs += [mlib]

    if mlib not in runtime_library_dirs and mlib != '':
        runtime_library_dirs += [mlib]

###################
# SCALAPACK
###################
if 'scalapack' not in libraries:
    tmpdir = Path('/usr/lib/x86_64-linux-gnu')
    if (tmpdir / 'libscalapack.so').exists():
        scalapack = True
        libraries += ['scalapack']
    elif (tmpdir / 'libscalapack-mpi.so').exists():
        scalapack = True
        libraries += ['scalapack-mpi']

if 'openblas' not in libraries:
    libraries += ['openblas']

if 1:
    libxc = True
    if 'xc' not in libraries:
        libraries += ['xc']

if 1:
    libvdwxc = True
    if 'vdwxc' not in libraries:
    	libraries += ['vdwxc']

###################
# FFTW3
###################
if 1:
    tmpdir = Path('/usr/include')
    if 'fftw3' not in libraries:
        if (tmpdir / 'libfftw3.so').exists():
            fftw = True
            libraries += ['fftw3']
    
    if 'fftw3' not in libraries:
        if (tmpdir / 'libfftw3_mpi.so').exists():
            fftw = True
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



USER ubuntu
WORKDIR /home/ubuntu

RUN << 'EOF'
ldd /usr/local/lib/python3.12/dist-packages/_gpaw.cpython-312-x86_64-linux-gnu.so
gpaw info
gpaw test
gpaw -P 4 test



EOF


