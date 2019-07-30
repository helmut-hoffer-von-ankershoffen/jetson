ARG base=max-one.local:5001/jetson/tensorflow-serving-base
FROM ${base}

MAINTAINER Helmut Hoffer von Ankershoffen <helmuthva@googlemail.com>

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

WORKDIR /

# Expose ports
# grpc
EXPOSE 8500
# rest
EXPOSE 8501
# webservice
EXPOSE 80
