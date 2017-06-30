FROM alpine:3.5
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
        pcre-dev 

RUN \
    # Agree to the stuff that cpan is asking in initial install
    echo "\n" | cpan \

    # Install needed perl modules 
    && cpan install Redis local::lib Test::More

# Version for which to test against
ENV NGINX_VERSION 1.11.2

# Install nginx
RUN \
	mkdir -p /build \
	&& cd /build \

	# Download  nginx
	&& echo wget "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz" \
    && wget "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz" \
    && tar -xzvf nginx-$NGINX_VERSION.tar.gz \
    && mv nginx-$NGINX_VERSION nginx \
    && rm nginx-$NGINX_VERSION.tar.gz

# Copy module files to build directory
ADD . /build/

    # Build nginx
RUN cd /build/nginx \
    && ./configure --prefix=/etc/nginx --add-module=/build/ \
    && make -j2 \
    && make install \
    && cd .. \

    # Create the dir for logs
    && mkdir -p /etc/nginx/logs \

	# Run tests
	&& prove -r t