FROM debian:stretch
MAINTAINER Onni Hakala - onni@keksi.io

# Install base utils
RUN \
    apt-get update && \
    apt-get -y install --no-install-recommends \
    	build-essential \
    	libreadline-dev \
    	libncurses5-dev \
    	libpcre3-dev \
    	libgeoip-dev \
    	zlib1g-dev \
    	ca-certificates \
    	wget \
    	clang \
    	redis-server > /tmp/apt-install.log 2>&1 || (cat /tmp/apt-install.log && exit 1)

# Agree to cpan automatically so we don't get interactive installer
RUN echo "\n" | cpan > /tmp/cpan-init.log 2>&1 || (cat /tmp/cpan-init.log && exit 1)

# Install needed perl modules
RUN cpan -T Redis local::lib Test::More Test::Nginx > /tmp/cpan-build.log 2>&1 || (cat /tmp/cpan-build.log && exit 1)

RUN mkdir -p /build
WORKDIR /build

# Downloads this version of nginx source code
ARG NGINX_VERSION=1.11.2

# Download nginx
RUN echo "Installing nginx version: ${NGINX_VERSION}" \
    && wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
    && tar -xzf nginx-${NGINX_VERSION}.tar.gz \
    && mv nginx-${NGINX_VERSION} nginx \
    && rm nginx-${NGINX_VERSION}.tar.gz

# Copy module files to build directory
ADD . /build/

# Allow changing between gcc and clang
ARG CC=gcc

# Build nginx
RUN cd nginx \
    && readonly NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1)  \
    && echo "Using up to $NPROC threads for make" \
    && ./configure --prefix=/etc/nginx --add-module=/build/ \
    && make -j${NPROC} > /tmp/make.log 2>&1 || (cat /tmp/make.log && exit 1) \
    && make -j${NPROC} install > /tmp/make.log 2>&1 || (cat /tmp/make.log && exit 1) \
    && cd .. \

    # Create the dir for logs
    && mkdir -p /etc/nginx/logs

# Use local libraries from test directory
# Add newly built nginx into path
ENV PERL5LIB="/build/t:$PERL5LIB" \
    PATH="/build/nginx/objs:$PATH"

# Run tests
RUN prove -r t