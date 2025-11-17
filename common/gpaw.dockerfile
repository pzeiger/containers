
RUN << 'EOF'
GPAW_CONFIG={install_prefix}/gpaw/siteconfig.py
tee ${GPAW_CONFIG=} << INNER_EOF
if '-fopenmp' not in extra_compile_args:
    extra_compile_args += ['-fopenmp']

if '-fopenmp' not in extra_link_args:
    extra_link_args += ['-fopenmp']

scalapack = True
if 'scalapack' not in libraries:
    libraries += ['scalapack']

if 'openblas' not in libraries:
    libraries += ['openblas']


#blacs = True
#if 'blacs' not in libraries:
#    libraries += ['blacs']
    
#runtime_library_dirs += ['/usr/lib64/mpi/gcc/openmpi4/lib64', '/usr/lib64']
#library_dirs += ['/usr/lib64/mpi/gcc/openmpi5/lib64', '/usr/lib64']
#extra_link_args += ['/usr/lib64/mpi/gcc/openmpi5/lib64', '/usr/lib64']

fftw = True
if 'fftw3' not in libraries:
    libraries += ['fftw3']

#library_dirs += ['/usr/lib64']
#include_dirs += ['/usr/include']
#runtime_library_dirs += ['/usr/lib64']

INNER_EOF

pip install gpaw[full]

EOF

