# ##################################################################################################
# Basic docker build of Generic HMI for use with Manticore:  https://github.com/smartdevicelink/generic_hmi
# ##################################################################################################

# This image has node and npm preinstalled
FROM node:7.10.0-slim

MAINTAINER Chris Rokita version:1.0

ARG HMI_VERSION=minimal 
ENV CORE_FILE_ADDR 127.0.0.1:3001
ENV BROKER_ADDR ws:\/\/127.0.0.1:9000

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    nginx 

# Download Generic HMI from github 

RUN mkdir /usr/app/webapp
RUN git clone https://github.com/smartdevicelink/generic_hmi.git /usr/app/webapp -b $HMI_VERSION --depth=1

WORKDIR /usr/app/webapp

# Install dependencies and run webpack so we can guarantee the bundle.js file exists
# Remove everything but the build/bundle.js file and the index.html file 
RUN npm install \
	&& npm rebuild node-sass \
	&& ./node_modules/webpack/bin/webpack.js \
	&& mv build /usr/app/tmpbuild \
	&& mv index.html /usr/app/tmpindex.html \
	&& mv fonts /usr/app/tmpfonts \
	&& rm -rf * \
	&& mv /usr/app/tmpbuild build \
	&& mv /usr/app/tmpindex.html index.html \
	&& mv /usr/app/tmpfonts fonts 

# Copy SDL Core start script into container
COPY setup.sh setup.sh

# Delete default nginx configuration
RUN rm -v /etc/nginx/nginx.conf

# Copy our new configuration
COPY nginx.conf /etc/nginx/

# Configure logger
RUN ldconfig

# Expose the following ports
#   8080:  Returns index.html of HMI
EXPOSE 8080

# Run nginx
CMD ["/bin/bash", "setup.sh"]
