FROM alpine:3.6

RUN \
	# Install redis and buildtools
	apk add --update \
		redis \
		perl \
		build-base \
        curl \
        gd-dev \
        geoip-dev \
        libxslt-dev \
        linux-headers \
        make \
        perl-dev \
        readline-dev \
        zlib-dev \
        pcre-dev \
        wget > /tmp/apk-install.log 2>&1 || (cat /tmp/apk-install.log && exit 1)

# Install CPAN configuration so we don't get interactive installer
RUN echo "\n" | cpan > /tmp/cpan-init.log 2>&1 || (cat /tmp/cpan-init.log && exit 1)

# Install needed perl modules
RUN cpan -T Redis local::lib Test::More > /tmp/cpan-build.log 2>&1 || (cat /tmp/cpan-build.log && exit 1)

RUN mkdir -p /build
WORKDIR /build

# Version for which to test against
ARG NGINX_VERSION=1.11.2

# Download nginx
RUN echo "Installing nginx version: ${NGINX_VERSION}" \
    && wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
    && tar -xzf nginx-${NGINX_VERSION}.tar.gz \
    && mv nginx-${NGINX_VERSION} nginx \
    && rm nginx-${NGINX_VERSION}.tar.gz

# Copy module files to build directory
ADD . /build/

# Allow changing the compiler
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

# Run tests
RUN prove -r t