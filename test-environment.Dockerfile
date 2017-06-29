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

    # Install nginx testing util: http://search.cpan.org/perldoc?Test::Nginx
    && cpan install Test::Nginx \

    # Install Redis library for perl
    && cpan install Redis 

# Copy files to docker
ADD . /build

# Run the tests
RUN \
	cd /build \

	&& prove -r t