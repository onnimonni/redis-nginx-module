test: start-services test-alpine test-debian-gcc test-debian-clang stop-services
	
start-services:
	docker-compose -f t/misc/docker-compose-services.yml up -d

stop-services:
	docker-compose -f t/misc/docker-compose-services.yml stop
	docker-compose -f t/misc/docker-compose-services.yml rm -f

test-alpine:
	# Installs all dependencies, builds nginx with redis module and runs tests
	# in alpine container
	docker build -t ngx-redis-test:alpine -f t/misc/test-alpine.Dockerfile --build-arg NGINX_VERSION=1.9.15 .
	docker run -it --rm --network="container:ngx_redis_server" ngx-redis-test:alpine sh -c "nginx -v && prove -r t"

test-debian-gcc:
	# Installs all dependencies, builds nginx with redis module and runs tests
	# in debian container
	docker build -t ngx-redis-test:debian-gcc -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=1.9.15 .
	docker run -it --rm --network="container:ngx_redis_server" ngx-redis-test:debian-gcc sh -c "nginx -v && prove -r t"

test-debian-clang:
	# Installs all dependencies, builds nginx with redis module and runs tests
	# in debian container
	docker build -t ngx-redis-test:debian-clang -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=1.9.15 .
	docker run -it --rm --network="container:ngx_redis_server" ngx-redis-test:debian-clang sh -c "nginx -v && prove -r t"

# This uses debian because glibc has longer support for nginx than musl
# Alpine is supported from 1.6.3 and forward
test-multi-version:
	docker-compose build --build-arg NGINX_VERSION=1.13.0  nginx-debian
	docker-compose build --build-arg NGINX_VERSION=1.12.0  nginx-debian
	docker-compose build --build-arg NGINX_VERSION=1.11.13 nginx-debian
	docker-compose build --build-arg NGINX_VERSION=1.11.2  nginx-debian
	docker-compose build --build-arg NGINX_VERSION=1.10.3  nginx-debian
	docker-compose build --build-arg NGINX_VERSION=1.9.15  nginx-debian
	docker-compose build --build-arg NGINX_VERSION=1.8.1   nginx-debian
	docker-compose build --build-arg NGINX_VERSION=1.7.10  nginx-debian
	docker-compose build --build-arg NGINX_VERSION=1.6.3   nginx-debian
	docker-compose build --build-arg NGINX_VERSION=1.4.7   nginx-debian
	docker-compose build --build-arg NGINX_VERSION=1.2.9   nginx-debian
	docker-compose build --build-arg NGINX_VERSION=1.0.15  nginx-debian
	#docker build -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=0.8.55  . # <- Not working because this debian container has too new openssl lib