# Use distribution used in JetPack 4.2
FROM ubuntu:bionic

MAINTAINER Helmut Hoffer von Ankershoffen <helmuthva@googlemail.com>

# Set non interactive frontend during build
ENV DEBIAN_FRONTEND=noninteractive

#  Set locale and lang
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Set local timezone
ENV TZ=Europe/Berliln
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Setup search path for shared libraries
ENV LD_LIBRARY_PATH="/lib/aarch64-linux-gnu:${LD_LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="/usr/lib/aarch64-linux-gnu/tegra:${LD_LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="/usr/lib/aarch64-linux-gnu:${LD_LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda-10.0/lib64:${LD_LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib/:${LD_LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="/opt/archiconda3/lib:${LD_LIBRARY_PATH}"

# Install common packages
RUN apt-get update && \
    apt-get install -y \
    apt-utils \
    automake \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    dnsutils \
    file \
    freeglut3-dev \
    git \
    hdf5-tools \
    htop \
    iotop \
    iputils-ping \
    less \
    libcurl3-dev \
    libfreetype6-dev \
    libglu1-mesa \
    libglu1-mesa-dev \
    libhdf5-dev \
    libhdf5-serial-dev \
    libjpeg8-dev \
    libpng-dev \
    libtool \
    libx11-dev \
    libxi-dev \
    libxmu-dev \
    libzmq3-dev \
    mlocate \
    nano \
    net-tools \
    nmap \
    ntp \
    openjdk-8-jdk\
    openjdk-8-jre-headless \
    patch \
    pkg-config \
    procps \
    python \
    python-dev \
    rsync \
    software-properties-common \
    sudo \
    swig \
    telnet \
    unzip \
    vim \
    wget \
    zip \
    zlib1g-dev \
    && \
    apt-get clean
RUN ln -sf /usr/lib/gcc/aarch64-linux-gnu/5/cc1plus /usr/local/bin/cc1plus

# Install Nvidia cuda libraries for nano inc. libcudnn, TensorRT and python bindings
RUN mkdir nano-cuda-deb && \
    cd nano-cuda-deb && \
    wget --quiet https://github.com/helmuthva/jetson/releases/download/0.1.0/nano-cuda-deb.tgz && \
    tar xzf nano-cuda-deb.tgz && \
    dpkg -i *.deb && \
    cd .. && \
    rm -rf nano-cuda-deb

# Install anaconda for arm64
RUN wget --quiet -O archiconda.sh https://github.com/Archiconda/build-tools/releases/download/0.2.3/Archiconda3-0.2.3-Linux-aarch64.sh && \
    sh archiconda.sh -b -p /opt/archiconda3 && \
    rm archiconda.sh
ENV PATH="/opt/archiconda3/bin:${PATH}"
RUN conda config --add channels gaiar && \
    conda config --add channels conda-forge && \
    conda config --add channels c4aarch64 && \
    conda update -n base --all && \
    conda install -y python=3.6.7 libiconv && \
    conda install -y conda-build && \
    conda install -y anaconda-client

# Install common python packages
RUN HDF5_DIR=/usr/lib/aarch64-linux-gnu/hdf5/serial/ pip install \
    absl-py \
    astor \
    future>=0.17.1 \
    gast \
    google-pasta \
    grpcio \
    h5py \
    keras-applications \
    keras-preprocessing \
    mock \
    numpy \
    pgen \
    portpicker \
    protobuf \
    psutil \
    py-cpuinfo \
    requests \
    six \
    termcolor \
    wrapt

# Install Nvidia flavored tensorflow with gpu/cuda support
RUN pip install --no-cache-dir https://developer.download.nvidia.com/compute/redist/jp/v42/tensorflow-gpu/tensorflow_gpu-1.13.1+nv19.5-cp36-cp36m-linux_aarch64.whl

