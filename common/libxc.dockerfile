
RUN mkdir libxc
WORKDIR libxc
RUN wget https://github.com/ElectronicStructureLibrary/libxc/archive/refs/tags/{version}.tar.gz
RUN tar xzf {version}.tar.gz
WORKDIR {version}

RUN cmake -H. -Bobjdir \
    -D CMAKE_INSTALL_PREFIX="/home/ubuntu/lib" \
    -D BUILD_SHARED_LIBS="ON" \
    cd objdir && make && make test && make install

RUN python setup.py install

WORKDIR /home/ubuntu
