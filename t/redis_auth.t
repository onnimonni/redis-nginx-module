# vi:ft=

use Test::Nginx::Socket 'no_plan';
use Redis;

eval { require Redis; };
plan(skip_all => 'Redis not installed') if $@;

# Load local helper module for running the redis daemon
use lib 'lib';
use ngxredis::Helper;

my $t = ngxredis::Helper->new();

# Override the port for the redis
$ENV{TEST_NGINX_REDIS_PORT} = 6780;
$ENV{TEST_NGINX_REDIS_AUTH} ||= 'secure_password';

# Prepare Redis server
$t->write_file('redis.conf', <<EOF);
daemonize no
pidfile ./redis.pid
port $ENV{TEST_NGINX_REDIS_PORT}
bind 127.0.0.1
timeout 1000
databases 16
dir ./
appendonly no
appendfsync always
requirepass $ENV{TEST_NGINX_REDIS_AUTH}
EOF

my $REDIS_SERVER = defined $ENV{TEST_REDIS_BINARY} ? $ENV{TEST_REDIS_BINARY} : '/usr/bin/redis-server';

$t->run_daemon($REDIS_SERVER, $t->testdir() . '/redis.conf');
$t->waitforsocket("127.0.0.1:$ENV{TEST_NGINX_REDIS_PORT}") or die "Can't start redis";

# Populate data into redis
my $r = Redis->new(server => "127.0.0.1:$ENV{TEST_NGINX_REDIS_PORT}");
$r->auth($ENV{TEST_NGINX_REDIS_AUTH}) or die "can't authenticate into redis: $!";
$r->set('/' => "SEE-THIS\n") or die "can't put value into redis: $!";

run_tests();

__DATA__

=== TEST 1: Get data with authentication
Get data from redis default database
--- config
location = / {
    set $redis_key $uri;
    set $redis_auth $TEST_NGINX_REDIS_AUTH;
    redis_pass 127.0.0.1:$TEST_NGINX_REDIS_PORT;
}
--- request
GET /
--- response_body
SEE-THIS
--- error_code: 200

=== TEST 2: Should fail when no AUTH is provided
Get data from redis default database
--- config
location = / {
    set $redis_key $uri;
    set $redis_auth '';
    redis_pass 127.0.0.1:$TEST_NGINX_REDIS_PORT;
}
--- request
GET /
--- error_code: 502

=== TEST 3: Get nonexistent data from Redis
Try to get data that is not inside Redis
--- config
location = /notfound {
    set $redis_key $uri;
    set $redis_auth $TEST_NGINX_REDIS_AUTH;
    redis_pass 127.0.0.1:$TEST_NGINX_REDIS_PORT;
}
--- request
GET /notfound
--- error_code: 404
