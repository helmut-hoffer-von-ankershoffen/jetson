ARG FROM=max-one.local:5001/jetson/nano/tensorflow-serving-base
FROM ${FROM}

MAINTAINER Helmut Hoffer von Ankershoffen <helmuthva@googlemail.com>

# Inc on updates of base image
ENV BUMP=1

# Install application server
RUN pip install \
    fastapi \
    uvicorn \
    email-validator

# Augment supervisord configuration
COPY /etc/supervisor/conf.d /etc/supervisor/conf.d

# Install app
COPY /webservice /webservice

# Install model
ENV MODEL_NAME=half_plus_two
COPY /models/testdata/saved_model_half_plus_two_mkl /models/half_plus_two

# Install testdata
COPY /models/testdata /testdata

#  Workdir is root
WORKDIR /

# Expose ports
# webservice
EXPOSE 80
# grpc
EXPOSE 8500
# rest
EXPOSE 8501

RUN mkdir -p /meta && \
    date +"%FT%T%Z" > /meta/tensorflow-serving.build
