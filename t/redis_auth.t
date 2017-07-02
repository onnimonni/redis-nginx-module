# vi:ft=

use Test::Nginx::Socket 'no_plan';
use Redis;

eval { require Redis; };
plan(skip_all => 'Redis not installed') if $@;

# Override the port for the redis
$ENV{TEST_NGINX_REDIS_AUTH_ENABLED_PORT} ||= 6380;
$ENV{TEST_NGINX_REDIS_AUTH_ENABLED_PASS} ||= 'password';

# Populate data into redis
my $r = Redis->new(server => "127.0.0.1:$ENV{TEST_NGINX_REDIS_AUTH_ENABLED_PORT}");

$r->auth($ENV{TEST_NGINX_REDIS_AUTH_ENABLED_PASS}) or die "can't authenticate into redis: $!";
$r->set('/' => "SEE-THIS\n") or die "can't put value into redis: $!";
$r->set('/0/' => "SEE-THIS.0\n") or die "can't put value into redis: $!";

$r->select('1') or die "can't select db 1 in redis: $!";
$r->set('/1/' => "SEE-THIS.1\n") or die "can't put value into redis: $!";

run_tests();

__DATA__

=== TEST 1: Get data with authentication
Get data from redis default database
--- config
location = / {
    set $redis_key $uri;
    set $redis_auth $TEST_NGINX_REDIS_AUTH_ENABLED_PASS;
    redis_pass 127.0.0.1:$TEST_NGINX_REDIS_AUTH_ENABLED_PORT;
}
--- request
GET /
--- response_body
SEE-THIS
--- error_code: 200

=== TEST 3: Get data from database number 1 with authentication
Get data from a database number which is different than the default
--- config
location = /1/ {
    set $redis_key $uri;
    set $redis_db "1";
    set $redis_auth $TEST_NGINX_REDIS_AUTH_ENABLED_PASS;
    redis_pass 127.0.0.1:$TEST_NGINX_REDIS_AUTH_ENABLED_PORT;
}
--- request
GET /1/
--- response_body
SEE-THIS.1
--- error_code: 200

=== TEST 4: Should fail when no AUTH is provided
Get data from redis default database
--- config
location = / {
    set $redis_key $uri;
    set $redis_auth '';
    redis_pass 127.0.0.1:$TEST_NGINX_REDIS_AUTH_ENABLED_PORT;
}
--- request
GET /
--- error_code: 502

=== TEST 5: Get nonexistent data from Redis
Try to get data that is not inside Redis
--- config
location = /notfound {
    set $redis_key $uri;
    set $redis_auth $TEST_NGINX_REDIS_AUTH_ENABLED_PASS;
    redis_pass 127.0.0.1:$TEST_NGINX_REDIS_AUTH_ENABLED_PORT;
}
--- request
GET /notfound
--- error_code: 404
