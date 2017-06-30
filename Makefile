test: test-alpine test-debian-gcc test-debian-clang

test-alpine:
	# Installs all dependencies, builds nginx with redis module and runs tests
	# in alpine container
	docker build -f t/misc/test-alpine.Dockerfile .

test-debian-gcc:
	# Installs all dependencies, builds nginx with redis module and runs tests
	# in debian container
	docker build -f t/misc/test-debian.Dockerfile --build-arg CC=gcc .

test-debian-clang:
	# Installs all dependencies, builds nginx with redis module and runs tests
	# in debian container
	docker build -f t/misc/test-debian.Dockerfile --build-arg CC=clang .

# This uses debian because glibc has longer support for nginx than musl
# Alpine is supported from 1.6.3 and forward
test-multi-version:
	docker build -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=1.13.2  .
	docker build -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=1.12.0  .
	docker build -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=1.11.13 . 
	docker build -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=1.11.2  . 
	docker build -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=1.10.3  . 
	docker build -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=1.9.15  .
	docker build -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=1.8.1   .
	docker build -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=1.7.10  .
	docker build -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=1.6.3   .
	docker build -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=1.4.7   .
	docker build -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=1.2.9   .
	docker build -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=1.0.15  .
	#docker build -f t/misc/test-debian.Dockerfile --build-arg NGINX_VERSION=0.8.55  . # <- Not working because this debian container has too new openssl lib