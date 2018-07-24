# ##################################################################################################
# Basic docker build of SDL Core for use with Manticore:  https://github.com/smartdevicelink/sdl_core
# ##################################################################################################

# This image is based of debian
FROM buildpack-deps:jessie-curl

MAINTAINER Chris Rokita version:1.0

ARG CORE_VERSION=master 
ARG CORE_NETWORK_INTERFACE=eth0 
ARG DBUILD_AVAHI_SUPPORT=OFF 
ARG DBUILD_USB_SUPPORT=OFF 
ARG DBUILD_BT_SUPPORT=OFF 
ARG DEXTENDED_MEDIA_MODE=OFF 
ARG DENABLE_HMI_PTU_DECRYPTION=OFF 

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \ 
        cmake \
        libudev-dev \
        libsqlite3-dev \
        libssl-dev \
        nginx \
        python \
        sudo \
        supervisor \
        sqlite3 \
        git 

# Download SDL Core from github
WORKDIR /usr

RUN mkdir /usr/sdl_core
RUN git clone https://github.com/smartdevicelink/sdl_core.git /usr/sdl_core -b $CORE_VERSION --depth=1

RUN mkdir /usr/build

# Work inside the build folder
WORKDIR /usr/build

# Generate our Makefile, compile it and install
# Remove everything but what's inside the bin folder of the build directory to save space
RUN cmake -DBUILD_AVAHI_SUPPORT=$DBUILD_AVAHI_SUPPORT \
    -DBUILD_USB_SUPPORT=$DBUILD_USB_SUPPORT \
    -DBUILD_BT_SUPPORT=$DBUILD_BT_SUPPORT \
    -DEXTENDED_MEDIA_MODE=$DEXTENDED_MEDIA_MODE \
    -DENABLE_HMI_PTU_DECRYPTION=$DENABLE_HMI_PTU_DECRYPTION \
    ../sdl_core \
    && make \
    && make install \
    && mv bin /usr/tmpbin \
    && rm -rf * \
    && mv /usr/tmpbin bin 
    
RUN mkdir -p /usr/web/logstream 
WORKDIR /usr/web/logstream

# Copy node and npm files
COPY package.json /usr/web/logstream/package.json
COPY package-lock.json /usr/web/logstream/package-lock.json
COPY server.js /usr/web/logstream/server.js

# Install nvm and dependencies
RUN curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh -o install_nvm.sh
RUN bash install_nvm.sh
RUN /bin/bash -c "source /root/.bashrc; \
    nvm install v8.11.1 \
    nvm use v8.11.1 \
    nvm alias default v8.11.1; \
    npm install"

# Download and setup the broker
RUN mkdir -p /usr/web/broker \
    && curl -sSL https://github.com/smartdevicelink/sdl_broker/archive/master.tar.gz \
    | tar -v -C /usr/web/broker -xz --strip-components 1

WORKDIR /usr/web/broker
RUN /bin/bash -c "source /root/.bashrc; \
    npm install"

# Directory to run commands in
WORKDIR /usr/build/bin

# Copy SDL Core start script into container
COPY setup.sh setup.sh

ENV LD_LIBRARY_PATH /usr/build/bin/

# Configure logger
RUN ldconfig

# Delete default nginx configuration
RUN rm -v /etc/nginx/nginx.conf

# Copy new nginx configuration
COPY nginx.conf /etc/nginx

# Copy supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Replace log file with a custom made one
COPY log4cxx.properties /usr/build/bin/log4cxx.properties

# Expose the following ports
#   3001: Expose SDL Core's file system
#   12345: Expose SDL Core's primary port. Used to communicate with the SDL Core instance over TCP
#   5050: Expose video streaming port
#   5080: Expose audio streaming port
#   8090: Expose time testing port
#   8888: Expose websocket port for core log streaming
#   9000:  Websocket connection to the broker
EXPOSE 3001 12345 5050 5080 8090 8888 9000

# Run the start script that will launch SDL Core!
CMD ["/bin/bash", "setup.sh"]