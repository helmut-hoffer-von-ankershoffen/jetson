FROM max-one.local:5001/jetson/ml-base

MAINTAINER Helmut Hoffer von Ankershoffen <helmuthva@googlemail.com>

# Build bazel build
RUN wget --quiet https://github.com/bazelbuild/bazel/releases/download/0.24.1/bazel-0.24.1-dist.zip && \
    mkdir bazel-0.24.1 && \
    unzip -q bazel-0.24.1-dist.zip -d bazel-0.24.1 && \
    cd bazel-0.24.1 && \
    ./compile.sh && \
    cp -f output/bazel /usr/local/bin && \
    cd .. && \
    rm -rf bazel*

# Build TF serving from source using bazel build including Python binding
WORKDIR /tensorflow-serving
ARG TF_SERVING_VERSION_GIT_BRANCH=master
ARG TF_SERVING_VERSION_GIT_COMMIT=head
ENV TF_NEED_CUDA=1
ENV TF_TENSORRT_VERSION=5.1.6
ENV CUDNN_VERSION=7.5.0
ENV TMP=/tmp
ENV BAZEL_PYTHON=/opt/archiconda3/bin/python
COPY /.bazelrc /tmp/.bazelrc
RUN git clone --branch=${TF_SERVING_VERSION_GIT_BRANCH} https://github.com/tensorflow/serving . && \
    git remote add upstream https://github.com/tensorflow/serving.git && \
    if [ "${TF_SERVING_VERSION_GIT_COMMIT}" != "head" ]; then git checkout ${TF_SERVING_VERSION_GIT_COMMIT} ; fi && \
    \
    mv /tmp/.bazelrc .bazelrc && \
    \
    ln -sf /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 && \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:${LD_LIBRARY_PATH} \
    \
    bazel \
    build \
    --color=yes \
    --curses=yes \
    --jobs="1" \
    --verbose_failures \
    --output_filter=DONT_MATCH_ANYTHING \
    --config=cuda \
    --config=nativeopt \
    --copt="-fPIC"\
    tensorflow_serving/model_servers:tensorflow_model_server && \
    cp /tensorflow-serving/bazel-bin/tensorflow_serving/model_servers/tensorflow_model_server /usr/local/bin/tensorflow_model_server && \
    rm -f /usr/local/cuda/lib64/stubs/libcuda.so.1 && \
    \
    bazel build --color=yes --curses=yes \
    --color=yes \
    --curses=yes \
    --jobs="1" \
    --verbose_failures \
    --output_filter=DONT_MATCH_ANYTHING \
    --config=cuda \
    --config=nativeopt \
    --copt="-fPIC"\
    tensorflow_serving/tools/pip_package:build_pip_package && \
    bazel-bin/tensorflow_serving/tools/pip_package/build_pip_package \
    /tmp/pip && \
    pip --no-cache-dir install \
    /tmp/pip/tensorflow_serving_api_gpu-*.whl && \
    rm -rf /tmp/pip && \
    \
    rm  -rf /tensorflow-serving

# Create model directory
WORKDIR /
ENV MODEL_BASE_PATH=/models
RUN mkdir -p ${MODEL_BASE_PATH}

# Install app
WORKDIR /app
RUN pip install \
    fastapi \
    uvicorn \
    email-validator
COPY /app /app

# Expose ports
# API
EXPOSE 80
# gRPC
EXPOSE 8500
# REST
EXPOSE 8501

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]


