FROM nvcr.io/nvidia/l4t-base:r32.1

MAINTAINER Helmut Hoffer von Ankershoffen <helmuthva@googlemail.com>

# Set non interactive frontend during build
ENV DEBIAN_FRONTEND=noninteractive

#  Set locale and lang
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Set local timezone
ENV TZ=Europe/Berliln
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

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
    gnupg2 \
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

# Build and install device query
COPY /samples /samples
RUN cd /samples/1_Utilities/deviceQuery && \
    make clean && \
    make && \
    mkdir /app && \
    cp deviceQuery /app/deviceQuery

# Execute deviceQuery to validate cuda and driver access on boot than sleep
CMD exec /bin/bash -c "trap : TERM INT; /app/deviceQuery; echo \"Sleeping until terminated - press ctrl+c...\"; sleep infinity & wait"s