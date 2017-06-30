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
        pcre-dev \

    # Agree to the stuff that cpan is asking for
    && echo "\n" | cpan \
    && cpan install App::cpanminus

# Version for which to test against
ENV NGINX_VERSION 1.11.2

# Copy files to docker
ADD . /build

# Run the tests
RUN \
	cd /build \

	# Install test dependencies
	&& cpanm --installdeps ./t/ \

	# Download  nginx
    && wget 'http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz' \
    && tar -xzvf nginx-$NGINX_VERSION.tar.gz \
    && mv nginx-$NGINX_VERSION nginx \

    # Build nginx
    && cd nginx \
    && ./configure --prefix=/etc/nginx --add-module=/build/ \
    && make -j2 \
    && make install \
    && cd .. \

    # Create the dir for logs
    && mkdir -p /etc/nginx/logs \

	# Run tests
	&& prove -r t