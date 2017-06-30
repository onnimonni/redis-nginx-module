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
