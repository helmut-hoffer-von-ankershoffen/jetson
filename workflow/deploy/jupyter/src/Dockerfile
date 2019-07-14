# Use distribution used in JetPack 4.2
FROM ubuntu:bionic

MAINTAINER Helmut Hoffer von Ankershoffen <helmuthva@googlemail.com>

ARG DEBIAN_FRONTEND=noninteractive

# Set local timezone
ENV TZ=Europe/Berliln
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install basic packages
RUN apt-get update && \
    apt-get install -y \
    apt-utils \
    software-properties-common \
    procps \
    less \
    nano \
    vim \
    telnet \
    iputils-ping \
    net-tools \
    dnsutils \
    nmap \
    ntp \
    telnet \
    sudo \
    wget \
    curl \
    zip \
    bzip2 \
    build-essential \
    git \
    rsync \
    patch \
    file \
    htop \
    iotop \
    && \
    apt-get clean
RUN ln -sf /usr/lib/gcc/aarch64-linux-gnu/5/cc1plus /usr/local/bin/cc1plus

# Install anaconda for arm64
RUN wget -O archiconda.sh https://github.com/Archiconda/build-tools/releases/download/0.2.3/Archiconda3-0.2.3-Linux-aarch64.sh
RUN sh archiconda.sh -b -p /opt/archiconda3 && \
    rm archiconda.sh
ENV PATH="/opt/archiconda3/bin:${PATH}"
RUN conda config --add channels gaiar
RUN conda config --add channels conda-forge
RUN conda config --add channels c4aarch64
RUN conda update -n base --all
RUN conda install -y python=3.6.7 libiconv
RUN conda install -y conda-build
RUN conda install -y anaconda-client

# Install seaborn
RUN conda install -y seaborn

# Install jupyter
RUN conda install -y jupyter
RUN pip uninstall -y tornado && \
    pip uninstall -y nbconvert
RUN pip install tornado==4.2
RUN pip install nbconvert==5.3.1

# Install keras et al
RUN apt-get update && \
    apt-get install -y \
    libhdf5-serial-dev \
    libhdf5-dev \
    hdf5-tools \
    zlib1g-dev \
    libjpeg8-dev \
    && \
    apt-get clean
RUN HDF5_DIR=/usr/lib/aarch64-linux-gnu/hdf5/serial/ pip install \
    h5py \
    pgen \
    numpy \
    grpcio \
    absl-py \
    py-cpuinfo \
    psutil \
    portpicker \
    six \
    mock \
    requests \
    gast \
    astor \
    termcolor \
    protobuf \
    keras-applications \
    keras-preprocessing \
    wrapt \
    google-pasta

# Install tensorflow with gpu/cuda support
RUN pip install --no-cache-dir --no-deps https://developer.download.nvidia.com/compute/redist/jp/v42/tensorflow-gpu/tensorflow_gpu-1.13.1+nv19.5-cp36-cp36m-linux_aarch64.whl

# Setup search path for shared libraries
ENV LD_LIBRARY_PATH="/lib/aarch64-linux-gnu:${LD_LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="/usr/lib/aarch64-linux-gnu/tegra:${LD_LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="/usr/lib/aarch64-linux-gnu:${LD_LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda-10.0/lib64:${LD_LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib/:${LD_LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="/opt/archiconda3/lib:${LD_LIBRARY_PATH}"

# Inject jupyter configuration and initial notebook
COPY jupyter_notebook_config.py /root/.jupyter/
ADD tf-tutorials.tgz /notebook
WORKDIR "/notebook"
CMD ["jupyter", "notebook", "--allow-root", "--no-browser" ]

# Expose jupyter and tensorboard
EXPOSE 8888
EXPOSE 6006
