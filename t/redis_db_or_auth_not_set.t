#!/usr/bin/perl

# (C) Maxim Dounin
# (C) Sergey A. Osokin

# Test for redis backend.

###############################################################################

use warnings;
use strict;

use Test::More;

BEGIN { use FindBin; chdir($FindBin::Bin); }

use lib 'lib';
use Test::Nginx;

###############################################################################

select STDERR; $| = 1;
select STDOUT; $| = 1;

eval { require Redis; };
plan(skip_all => 'Redis not installed') if $@;

my $t = Test::Nginx->new()->has(qw/http redis/)
	->has_daemon('redis-server')->plan(1)
	->write_file_expand('nginx.conf', <<'EOF');

%%TEST_GLOBALS%%

daemon         off;

events {
}

http {
    %%TEST_GLOBALS_HTTP%%

    upstream redisbackend {
        server 127.0.0.1:8083;
    }

    server {
        listen       127.0.0.1:8080;
        server_name  localhost;

        location / {
            set $redis_key $uri;
            redis_pass redisbackend;
        }
    }
}

EOF

$t->run();

$t->write_file('redis.conf', <<EOF);

daemonize no
pidfile ./redis.pid
port 8083
bind 127.0.0.1
timeout 300
loglevel debug
logfile ./redis.log
databases 16
save 900 1
save 300 10
save 60 10000
rdbcompression yes
dbfilename dump.rdb
dir ./
appendonly no
appendfsync always

EOF

$t->run_daemon('redis-server', $t->testdir() . '/redis.conf');
$t->run();

$t->waitforsocket('127.0.0.1:8083')
    or die "Can't start redis";

###############################################################################

my $r = Redis->new(server => '127.0.0.1:8083');
$r->set('/' => 'SEE-THIS') or die "can't put value into redis: $!";
$r->set('/0/' => 'SEE-THIS.0') or die "can't put value into redis: $!";

$r->select("1") or die "can't select db 1 in redis: $!";
$r->set('/1/' => 'SEE-THIS.1') or die "can't put value into redis: $!";

like(http_get('/'), qr/SEE-THIS/, 'redis request /');

like(http_get('/0/'), qr/SEE-THIS.0/, 'redis request from db 0');

like(http_get('/1/'), qr/SEE-THIS.1/, 'redis request from db 1');

like(http_get('/0/'), qr/SEE-THIS.0/, 'redis request from db 0');

unlike (http_head('/'), qr/SEE-THIS/, 'redis no data in HEAD');

###############################################################################


