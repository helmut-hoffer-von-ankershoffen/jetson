ARG FROM=max-one.local:5001/jetson/nano/ml-base
FROM ${FROM}

MAINTAINER Helmut Hoffer von Ankershoffen <helmuthva@googlemail.com>

# Number of parallel jobs when building TensorFlow serving
ARG JOBS=1

# CUDA capabilities of Jetson (Nano, TX1, TX2 and Xavier)
ARG TF_CUDA_COMPUTE_CAPABILITIES
ENV TF_CUDA_COMPUTE_CAPABILITIES ${TF_CUDA_COMPUTE_CAPABILITIES:-5.3,6.2,7.2}

# JETSON_MODEL used in .bazelrc
ARG JETSON_MODEL
ENV JETSON_MODEL ${JETSON_MODEL:-nano}

# Install supervisord
RUN apt-get update && \
    apt-get install -y supervisor && \
    apt-get clean && \
    mkdir -p /var/log/supervisor

# Build bazel build
ENV BAZEL_VERSION=0.24.1
RUN wget --quiet https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-dist.zip && \
    mkdir bazel-$BAZEL_VERSION && \
    unzip -q bazel-$BAZEL_VERSION-dist.zip -d bazel-$BAZEL_VERSION && \
    cd bazel-$BAZEL_VERSION && \
    ./compile.sh && \
    cp -f output/bazel /usr/local/bin && \
    cd .. && \
    rm -rf bazel*

# Build TF serving from source using bazel build including Python binding
WORKDIR /
ENV TF_SERVING_VERSION_GIT_BRANCH=master
ENV TF_SERVING_VERSION_GIT_COMMIT=master
# TensorRT version as provided by ml-base
ENV TF_TENSORRT_VERSION=5.1.6
# CUDNN version as provided by ml-base
ENV CUDNN_VERSION=7.5.0
# CUDA as provided by ml-base
ENV TF_NEED_CUDA=1
# Use TensorRT as provided in ml-base
ENV TF_NEED_TENSORRT=1
# Required for ncc
ENV TMP=/tmp
# Use python of Anaconda as provided in ml-base
ENV BAZEL_PYTHON=/opt/archiconda3/bin/python
COPY /.bazelrc /tmp/tfs.bazelrc
RUN mkdir -p /tensorflow-serving && \
    cd /tensorflow-serving && \
    git clone --branch=${TF_SERVING_VERSION_GIT_BRANCH} --recurse-submodules https://github.com/tensorflow/serving . && \
    git remote add upstream https://github.com/tensorflow/serving.git && \
    if [ "${TF_SERVING_VERSION_GIT_COMMIT}" != "head" ]; then git checkout ${TF_SERVING_VERSION_GIT_COMMIT} ; fi && \
    \
    mv -f /tmp/tfs.bazelrc .bazelrc && \
    \
    bazel build \
    --color=yes \
    --curses=yes \
    --jobs="${JOBS}" \
    --verbose_failures \
    --output_filter=DONT_MATCH_ANYTHING \
    --config=cuda \
    --config=nativeopt \
    --config=jetson \
    --config=${JETSON_MODEL} \
    --copt="-fPIC" \
    tensorflow_serving/model_servers:tensorflow_model_server && \
    cp /tensorflow-serving/bazel-bin/tensorflow_serving/model_servers/tensorflow_model_server /usr/local/bin/tensorflow_model_server && \
    \
    bazel build \
    --color=yes \
    --curses=yes \
    --jobs="${JOBS}" \
    --verbose_failures \
    --output_filter=DONT_MATCH_ANYTHING \
    --config=cuda \
    --config=nativeopt \
    --config=jetson \
    --config=${JETSON_MODEL} \
    --copt="-fPIC" \
    tensorflow_serving/tools/pip_package:build_pip_package && \
    bazel-bin/tensorflow_serving/tools/pip_package/build_pip_package \
    /tmp/pip && \
    pip --no-cache-dir install \
    /tmp/pip/tensorflow_serving_api_gpu-*.whl && \
    \
    cd / && \
    rm -rf /tmp/pip && \
    rm -rf /root/.cache && \
    rm -rf /tensorflow-serving

# Create model directory
ENV MODEL_BASE_PATH=/models
ENV MODEL_NAME=default
RUN mkdir -p ${MODEL_BASE_PATH}

# Install supervisord configuration
COPY /etc/supervisor/conf.d /etc/supervisor/conf.d

# Expose ports
# grpc
EXPOSE 8500
# rest
EXPOSE 8501

CMD ["/usr/bin/supervisord"]

# Inc on updates of base image
ENV BUMP=3

RUN mkdir -p /meta && \
    printf "Built on: %s\n" "$(hostname)" > /meta/tensorflow-serving-base.build && \
    printf "Build completed: %s\n" "$(date "+%FT%T.%3NZ")" >> /meta/tensorflow-serving-base.build && \
    printf "Bump: %s\n" "${BUMP}" >> /meta/tensorflow-serving-base.build
