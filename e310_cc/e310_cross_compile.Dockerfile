
FROM        ubuntu:18.04
MAINTAINER  Trung Tran

# Last build date - this can be updated whenever there are security updates so
# that everything is rebuilt
ENV         security_updates_as_of 2018-20-09

# This will make apt-get install without question
ARG DEBIAN_FRONTEND=noninteractive

# Update package manager
RUN apt-get update
# Install UHD dependencies
RUN apt-get -y install -q \
        libboost-all-dev \
        libusb-1.0-0-dev \
        libudev-dev \
        python-mako \
        python-requests

# Install GNU Radio dependencies
RUN apt-get -y install -q \
        liblog4cpp5-dev \
        libfftw3-dev \
        python-numpy \
        libcppunit-dev \
        swig3.0 \
        libgsl-dev \
        python-lxml \
        python-cheetah
# Install other useful tools
RUN apt-get -y install -q \
        build-essential \
        ccache \
        git \
        curl \
        python-pip \
        cmake \
        pkgconf \
        vim \
        wget \
        openssh-server

RUN dpkg-reconfigure dash
RUN mkdir -p /e300/src
RUN cd /e300/src && git clone --depth=1 -b master --recursive -j8 https://github.com/EttusResearch/uhd.git
RUN wget http://files.ettus.com/e3xx_images/e3xx-release-4/oecore-x86_64-armv7ahf-vfp-neon-toolchain-nodistro.0.sh
RUN /bin/bash oecore-x86_64-armv7ahf-vfp-neon-toolchain-nodistro.0.sh -d /e300
RUN  /bin/bash -c "source /e300/environment-setup-armv7ahf-vfp-neon-oe-linux-gnueabi \
                    && cd /e300/src/uhd/host \
                    && mkdir build_cc\
                    && cd build_cc \
                    && cmake -DCMAKE_TOOLCHAIN_FILE=../host/cmake/Toolchains/oe-sdk_cross.cmake -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_E300=ON .. \
                    && make -j`nproc` \
                    && make install DESTDIR=/e300 \
                    && make install DESTDIR=/e300/sysroots/armv7ahf-vfp-neon-oe-linux-gnueabi/ \
                    && ldconfig"

RUN  cd /e300/src && git clone -b v3.7.10.2 --recursive https://github.com/gnuradio/gnuradio.git
RUN  /bin/bash -c "source /e300/environment-setup-armv7ahf-vfp-neon-oe-linux-gnueabi \
                    && cd /e300/src/gnuradio/ \
                    && mkdir build_cc\
                    && cd build_cc \
                    && cmake -Wno-dev -DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchains/oe-sdk_cross.cmake \
                                -DENABLE_GR_WXGUI=OFF \
                                -DENABLE_GR_VOCODER=OFF \
                                -DENABLE_GR_DTV=OFF \
                                -DENABLE_GR_ATSC=OFF \
                                -DENABLE_DOXYGEN=OFF \
                                -DCMAKE_INSTALL_PREFIX=/usr ../ \
                    && make -j`nproc` \
                    && make install DESTDIR=/e300 \
                    && make install DESTDIR=/e300/sysroots/armv7ahf-vfp-neon-oe-linux-gnueabi/"
RUN echo "LOCALPREFIX=~/localinstall/usr \\n \
        export PATH=\$LOCALPREFIX/bin:$PATH \\n \
        export LD_LOAD_LIBRARY=\$LOCALPREFIX/lib:$LD_LOAD_LIBRARY \\n \
        export LD_LIBRARY_PATH=\$LOCALPREFIX/lib:$LD_LIBRARY_PATH \\n \
        export PYTHONPATH=\$LOCALPREFIX/lib/python2.7/site-packages:$PYTHONPATH \\n \
        export PKG_CONFIG_PATH=\$LOCALPREFIX/lib/pkgconfig:$PKG_CONFIG_PATH \\n \
        export GRC_BLOCKS_PATH=\$LOCALPREFIX/share/gnuradio/grc/blocks:$GRC_BLOCKS_PATH \\n \
        export UHD_RFNOC_DIR=\$LOCALPREFIX/share/uhd/rfnoc/ \\n \
        export UHD_IMAGES_DIR=\$LOCALPREFIX/share/uhd/images \\n " > /e300/setupenv.sh
RUN mkdir /var/run/sshd
RUN echo 'root:e310_docker' | chpasswd
RUN echo "PermitRootLogin yes"  >> /etc/ssh/sshd_config
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
CMD ["/usr/sbin/sshd", "-D"]
