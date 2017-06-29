Name
====

**ngx_redis** - Brings "redis_pass" to get values from redis database.

*This module is not distributed with the Nginx source.* See [the installation instructions](#installation).

Table of Contents
=================

* [Name](#name)
* [Status](#status)
* [Version](#version)
* [Synopsis](#synopsis)
* [Description](#description)
* [Redis Handler Directives](#content-handler-directives)
    * [redis_pass](#redis_pass)
* [Variables](#variables)
    * [$redis_key](#redis_key)
    * [$redis_db](#redis_db)
    * [$redis_auth](#redis_auth)
* [Installation](#installation)
* [Compatibility](#compatibility)
* [Modules that use this module for testing](#modules-that-use-this-module-for-testing)
* [Community](#community)
    * [English Mailing List](#english-mailing-list)
    * [Chinese Mailing List](#chinese-mailing-list)
* [Report Bugs](#report-bugs)
* [Source Repository](#source-repository)
* [Changes](#changes)
* [Test Suite](#test-suite)
* [Getting involved](#getting-involved)
* [Author](#author)
* [Copyright & License](#copyright--license)
* [See Also](#see-also)

Status
======

This module is production ready.

Version
=======

This document describes redis_pass [v0.3.9](https://github.com/openresty/redis-nginx-module/tags).

Synopsis
========

```nginx
    location / {
      set $redis_key  "$uri?$args";
      redis_pass      127.0.0.1:6379;
    }
```

```nginx
    location / {
      set $redis_key  "$uri?$args";
      set $redis_db   "3";
      set $redis_auth "password";
      redis_pass      127.0.0.1:6379;
    }
```

```nginx
http
{
 ...
    upstream redis {
        server  127.0.0.1:6379;
    }

    server {
     ...
        location / {
            set $redis_key  "$uri?$args"
            proxy_pass redis;
        }
        ...
     }
}
```

[Back to TOC](#table-of-contents)

Description
===========

The nginx HTTP redis module for caching with [redis](https://github.com/antirez/redis).

The redis protocol implements `GET` and `SELECT` commands only.

This is fork of the [ngx_http_redis module by Sergey A. Osokin](https://www.nginx.com/resources/wiki/modules/redis/).

[Back to TOC](#table-of-contents)

Content Handler Directives
==========================

Variables
=========

[Back to TOC](#table-of-contents)

$redis_key
--------

The value of the [redis key](https://redis.io/topics/data-types-intro#redis-keys).

[Back to TOC](#table-of-contents)

$redis_db
-------------------

The redis database number to use. This is input value for [SELECT](https://redis.io/commands/select) command.

$redis_auth
-------------------

The redis authentication to use. This is input value for [AUTH](https://redis.io/commands/select) command.

[Back to TOC](#table-of-contents)

Installation
============

You're recommended to install this module (as well as the Nginx core and many other goodies) via the [OpenResty bundle](http://openresty.org). See [the detailed instructions](http://openresty.org/#Installation) for downloading and installing OpenResty into your system. This is the easiest and most safe way to set things up.

Alternatively, you can install this module manually with the Nginx source:

Grab the nginx source code from [nginx.org](http://nginx.org/), for example,
the version 1.11.2 (see [nginx compatibility](#compatibility)), and then build the source with this module:

```bash

 $ wget 'http://nginx.org/download/nginx-1.11.2.tar.gz'
 $ tar -xzvf nginx-1.11.2.tar.gz
 $ cd nginx-1.11.2/

 # Here we assume you would install you nginx under /opt/nginx/.
 $ ./configure --prefix=/opt/nginx \
     --add-module=/path/to/redis-nginx-module

 $ make -j2
 $ make install
```

Download the latest version of the release tarball of this module from [redis-nginx-module file list](https://github.com/openresty/redis-nginx-module/tags).

Starting from NGINX 1.9.11, you can also compile this module as a dynamic module, by using the `--add-dynamic-module=PATH` option instead of `--add-module=PATH` on the
`./configure` command line above. And then you can explicitly load the module in your `nginx.conf` via the [load_module](http://nginx.org/en/docs/ngx_core_module.html#load_module)
directive, for example,

```nginx
load_module /path/to/modules/ngx_http_echo_module.so;
```

Also, this module is included and enabled by default in the [OpenResty bundle](http://openresty.org).

[Back to TOC](#table-of-contents)

Community
=========

[Back to TOC](#table-of-contents)

English Mailing List
--------------------

The [openresty-en](https://groups.google.com/group/openresty-en) mailing list is for English speakers.

[Back to TOC](#table-of-contents)

Chinese Mailing List
--------------------

The [openresty](https://groups.google.com/group/openresty) mailing list is for Chinese speakers.

[Back to TOC](#table-of-contents)

Report Bugs
===========

Although a lot of effort has been put into testing and code tuning, there must be some serious bugs lurking somewhere in this module. So whenever you are bitten by any quirks, please don't hesitate to

1. create a ticket on the [issue tracking interface](https://github.com/openresty/redis-nginx-module/issues) provided by GitHub,
1. or send a bug report, questions, or even patches to the [OpenResty Community](#community).

[Back to TOC](#table-of-contents)

Source Repository
=================

Available on github at [openresty/redis-nginx-module](https://github.com/openresty/redis-nginx-module).

[Back to TOC](#table-of-contents)

Changes
=======
0.3.9 - 30 Jun 2017
-------------------
    *) Feature: it's now possible to use AUTH command with
       $redis_auth variable.
       Thanks to Wang Yongke (Yongke).

0.3.8 - 21 Feb 2016
-------------------

    *) Bugfix: it is impossible to compile the ngx_http_redis_module
       without http_gzip module or with --without-http_gzip_module
       option.
       Thanks to Yichun Zhang (agentzh).
 
    *) Feature: it's possible to compile as dynamic module now, this
       feature has been introduced in nginx 1.9.11.


0.3.7 - 28 Nov 2013
-------------------

    *) Bugfix: ngx_http_redis_module might issue the error message
       "redis sent invalid trailer" for nginx >= 1.5.3.
       Thanks to Maxim Dounin.


0.3.6 - 03 Apr 2012
-------------------

    *) Feature: redis_gzip_flag.  Useful if you are prefer to
       store data compressed in redis.  Works with ngx_http_gunzip_filter
       module.
       Thanks to Maxim Dounin.

    *) Bugfix: ngx_http_redis_module might issue the error message
       "redis sent invalid trailer".
       Thanks to agentzh.


0.3.5 - 30 Aug 2011
-------------------

    *) Feature: add test for not set $redis_db directive.

    *) Feature: keep-alive support merged from original
       memcached module 1.1.4.


0.3.4 - 24 Aug 2011
-------------------

    *) Change: better error messages diagnostics in select phase.

    *) Add more comments in source code.

    *) Bugfix: fix interaction with redis if redis_db was unused.
       Found by Sergey Makarov.
       Thanks to Igor Sysoev.

    *) Feature: add test suite for redis backend.
       Thanks to Maxim Dounin.


0.3.3 - 07 Jun 2011
-------------------

    *) Bugfix: fix interaction with redis if redis_db was used.
       Also, compile with -Werror now is possible.


0.3.2 - 17 Aug 2010
-------------------

    *) Bugfix: ngx_http_redis_module might issue the error message 
       "redis sent invalid trailer".  For more information see:
       $ diff -ruN \
             nginx-0.8.34/src/http/modules/ngx_http_memcached_module.c \
             nginx-0.8.35/src/http/modules/ngx_http_memcached_module.c

    *) Change: now the $redis_db set is not obligatory; default
       value is "0".


0.3.1 - 26 Dec 2009
-------------------

    *) Change: return 502 instead of 404 for error.

    *) Change: better error messages diagnostics.

    *) Bugfix: improve interoperability with redis; the bug had
       appeared in 0.3.0.


0.3.0 - 23 Dec 2009
-------------------

    *) Compatibility with latest stable (0.7.64) and
       development 0.8.31 releases.

    *) Bugfix: multiple commands issue with interoperability with
       redis; the bug had appeared in 0.2.0.

    *) Feature: redis_bind directive merge from original
       memcached module (for 0.8.22 and later).


0.2.0 - 19 Sep 2009
-------------------

    *) Feature: the $redis_db variable: now the ngx_http_redis
       module uses the $redis_db variable value as the parameter
       for SELECT command.

    *) Cleanup: style/spaces fixes.


0.1.2 - 14 Sep 2009
-------------------

    *) Change: backport to 0.7.61.


0.1.1 - 31 Aug 2009
-------------------

    *) Change: compatibility with nginx 0.8.11.
    
    *) Cleanup: mlcf -> rlcf, i.e.
       (memcached location configuration) -> redis...

[Back to TOC](#table-of-contents)

Test Suite
==========

This module comes with a Perl-driven test suite. The [test cases](https://github.com/openresty/redis-nginx-module/tree/master/t/) are
[declarative](https://github.com/openresty/redis-nginx-module/blob/master/t/echo.t) too. Thanks to the [Test::Nginx](http://search.cpan.org/perldoc?Test::Nginx) module in the Perl world.

To run it on your side:

```bash

 $ PATH=/path/to/your/nginx-with-echo-module:$PATH prove -r t
```

You need to terminate any Nginx processes before running the test suite if you have changed the Nginx server binary.

Because a single nginx server (by default, `localhost:1984`) is used across all the test scripts (`.t` files), it's meaningless to run the test suite in parallel by specifying `-jN` when invoking the `prove` utility.

Some parts of the test suite requires standard modules [proxy](http://nginx.org/en/docs/http/ngx_http_proxy_module.html), [rewrite](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html) and [SSI](http://nginx.org/en/docs/http/ngx_http_ssi_module.html) to be enabled as well when building Nginx.

[Back to TOC](#table-of-contents)

Getting involved
================

You'll be very welcomed to submit patches to the [author](#author) or just ask for a commit bit to the [source repository](#source-repository) on GitHub.

[Back to TOC](#table-of-contents)

Authors
=======

Sergey A. Osokin *&lt;osa@FreeBSD.org.ru&gt;*.

Yichun "agentzh" Zhang (章亦春) *&lt;agentzh@gmail.com&gt;*, OpenResty Inc.

Onni "onnimonni" Hakala *&lt;onni@keksi.io&gt;*, Keksi Labs Oy.

[Back to TOC](#table-of-contents)

Thanks to
=========

[Wang Yongke](https://github.com/Yongke) for his work on supporting redis AUTH with `$redis_auth`.

Maxim Dounin

Vsevolod Stakhov

Ezra Zygmuntowicz

Evan Miller for his "Guide To Nginx Module Development" and "Advanced Topics

In Nginx Module Development"

Valery Kholodkov for his "Nginx modules development"

Copyright & License
===================

    Copyright (C) 2002-2009 Igor Sysoev
    Copyright (C) 2009-2013,2016 Sergey A. Osokin
     
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
     
    THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
    FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
    OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
    HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
    OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
    SUCH DAMAGE.
 

[Back to TOC](#table-of-contents)

See Also
========

* The [original module in nginx.com](https://www.nginx.com/resources/wiki/modules/redis/).
* The [OpenResty](http://openresty.org) bundle.

[Back to TOC](#table-of-contents)
