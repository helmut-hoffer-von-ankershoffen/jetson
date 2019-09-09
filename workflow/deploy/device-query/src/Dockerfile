ARG FROM=max-one.local:5001/jetson/nano/ml-base
FROM ${FROM}

MAINTAINER Helmut Hoffer von Ankershoffen <helmuthva@googlemail.com>

# Build and install device query
RUN cd /usr/local/cuda/samples/1_Utilities/deviceQuery && \
    make clean && \
    make && \
    mkdir /app && \
    cp -f deviceQuery /app/deviceQuery

# Execute deviceQuery to validate cuda and driver access on boot than sleep
CMD exec /bin/bash -c "trap : TERM INT; /app/deviceQuery; echo \"Sleeping until terminated so you can see the log - press ctrl+c...\"; sleep infinity & wait"
