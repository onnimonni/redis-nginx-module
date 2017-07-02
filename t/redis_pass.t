# vi:ft=

use Test::Nginx::Socket 'no_plan';
use Redis;

eval { require Redis; };
plan(skip_all => 'Redis not installed') if $@;

# Load local helper module for running the redis-server daemon
use lib 'lib';
use ngxredis::Helper;

my $t = ngxredis::Helper->new();

# Override the port for the redis
$ENV{TEST_NGINX_REDIS_PORT} = 6780;

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
EOF

my $REDIS_SERVER = defined $ENV{TEST_REDIS_BINARY} ? $ENV{TEST_REDIS_BINARY} : '/usr/bin/redis-server';

$t->run_daemon($REDIS_SERVER, $t->testdir() . '/redis.conf');
$t->waitforsocket("127.0.0.1:$ENV{TEST_NGINX_REDIS_PORT}") or die "Can't start redis";

# Populate data into redis
my $r = Redis->new(server => "127.0.0.1:$ENV{TEST_NGINX_REDIS_PORT}");
$r->set('/' => "SEE-THIS\n") or die "can't put value into redis: $!";
$r->set('/0/' => "SEE-THIS.0\n") or die "can't put value into redis: $!";
$r->select("1") or die "can't select db 1 in redis: $!";
$r->set('/1/' => "SEE-THIS.1\n") or die "can't put value into redis: $!";

run_tests();

__DATA__

=== TEST 1: Get data from default Redis db
Get data from redis default database
--- config
location = / {
    set $redis_key $uri;
    redis_pass 127.0.0.1:$TEST_NGINX_REDIS_PORT;
}
--- request
GET /
--- response_body
SEE-THIS
--- error_code: 200

=== TEST 2: Get data explicitly from default db (0)
Get data explicitly from default Redis db
--- config
location = /0/ {
    set $redis_db 0;
    set $redis_key $uri;
    redis_pass 127.0.0.1:$TEST_NGINX_REDIS_PORT;
}
--- request
GET /0/
--- response_body
SEE-THIS.0
--- error_code: 200

=== TEST 3: Get data from db 1
Get data from redis database 1
--- config
location = /1/ {
    set $redis_db 1;
    set $redis_key $uri;
    redis_pass 127.0.0.1:$TEST_NGINX_REDIS_PORT;
}
--- request
GET /1/
--- response_body
SEE-THIS.1
--- error_code: 200

=== TEST 3: Get nonexistent data from Redis
Try to get data that is not inside Redis
--- config
location = /notfound {
    set $redis_key $uri;
    redis_pass 127.0.0.1:$TEST_NGINX_REDIS_PORT;
}
--- request
GET /notfound
--- error_code: 404

=== TEST 4: Empty response for HEAD request
HEAD requests should result in empty response
--- config
location = / {
    set $redis_key $uri;
    redis_pass 127.0.0.1:$TEST_NGINX_REDIS_PORT;
}
--- request
HEAD /
--- response_body
--- error_code: 200

=== TEST 5: Empty redis_auth should work when there's no requirepass
HEAD requests should result in empty response
--- config
location = / {
    set $redis_key $uri;
    set $redis_auth '';
    redis_pass 127.0.0.1:$TEST_NGINX_REDIS_PORT;
}
--- request
GET /
--- response_body
SEE-THIS
--- error_code: 200
