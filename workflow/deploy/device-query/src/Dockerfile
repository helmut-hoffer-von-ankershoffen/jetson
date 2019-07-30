ARG base=max-one.local:5001/jetson/ml-base
FROM ${base}

MAINTAINER Helmut Hoffer von Ankershoffen <helmuthva@googlemail.com>

# Build and install device query
RUN cd /usr/local/cuda/samples/1_Utilities/deviceQuery && \
    make clean && \
    make && \
    mkdir /app && \
    cp deviceQuery /app/deviceQuery

# Execute deviceQuery to validate cuda and driver access on boot than sleep
CMD exec /bin/bash -c "trap : TERM INT; /app/deviceQuery; echo \"Sleeping until terminated - press ctrl+c...\"; sleep infinity & wait"