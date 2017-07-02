Name
====

**ngx_redis** - Brings "redis_pass" to get values from redis database.

*This module is not distributed with the Nginx source.* See [the installation instructions](#installation).

[![Build Status](https://travis-ci.org/onnimonni/redis-nginx-module.svg?branch=master)](https://travis-ci.org/onnimonni/redis-nginx-module)

Table of Contents
=================

* [Name](#name)
* [Status](#status)
* [Version](#version)
* [Synopsis](#synopsis)
* [Description](#description)
* [Directives](#directives)
    * [redis_pass](#redis_pass)
    * [redis_bind](#redis_bind)
    * [redis_connect_timeout](#redis_connect_timeout)
    * [redis_read_timeout](#redis_read_timeout)
    * [redis_send_timeout](#redis_send_timeout)
    * [redis_buffer_size](#redis_buffer_size)
    * [redis_next_upstream](#redis_next_upstream)
* [Variables](#variables)
    * [$redis_key](#redis_key)
    * [$redis_db](#redis_db)
    * [$redis_auth](#redis_auth)
* [Installation](#installation)
* [Compatibility](#compatibility)
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

Directives
==========================

redis_pass
----------
**syntax:** *redis_pass &lt;host&gt;:&lt;port&gt;*

**default:** *no*

**context:** *location, location if*

**phase:** *content*

Specify the Redis server backend.

redis_bind
----------
**syntax:** *redis_bind &lt;addr&gt;*

**default:**  *none*

**context:**  **http, server, location**

Use the following IP address as the source address for redis connections.

redis_connect_timeout
---------------------
**syntax:** *redis_connect_timeout &lt;time&gt;*

**default:**  *60000*

**context:**  **http, server, location**

The timeout for connecting to redis, in milliseconds.

redis_read_timeout
------------------
**syntax:** *redis_read_timeout &lt;time&gt;*

**default:**  *60000*

**context:**  **http, server, location**

The timeout for reading from redis, in milliseconds.

redis_send_timeout
------------------
**syntax:** *redis_send_timeout &lt;time&gt;*

**default:**  *60000*

**context:**  **http, server, location**

The timeout for sending to redis, in milliseconds.

redis_buffer_size
-----------------
**syntax:** *redis_buffer_size &lt;size&gt;*

**default:**  *see getpagesize(2)*

**context:**  **http, server, location**

The recv/send buffer size, in bytes.

redis_next_upstream
-------------------
**syntax:** *redis_next_upstream &lt;error&gt; &lt;timeout&gt; &lt;invalid_response&gt; &lt;not_found&gt; &lt;off&gt;*

**default:**  *error timeout*

**context:**  **http, server, location**

Which failure conditions should cause the request to be forwarded to another upstream server? Applies only when the value in redis_pass is an upstream with two or more servers.

redis_gzip_flag
---------------------
**syntax:** *redis_gzip_flag &lt;number&gt;*

**default:**  *unset*

**context:**  **location**

Reimplementation of memcached_gzip_flag, see https://forum.nginx.org/read.php?29,34332,34463 for details.

[Back to TOC](#table-of-contents)

Variables
=========

$redis_key
--------

The value of the [redis key](https://redis.io/topics/data-types-intro#redis-keys).

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
load_module /path/to/modules/ngx_http_redis_module.so;
```

Also, this module is included and enabled by default in the [OpenResty bundle](http://openresty.org).

[Back to TOC](#table-of-contents)

Compatibility
=============

The following versions of Nginx should work with this module:

* **1.13.x**                      (last tested: 1.13.2)
* **1.12.x**                      (last tested: 1.12.0)
* **1.11.x**                      (last tested: 1.11.2)
* **1.10.x**                      (last tested: 1.10.3)
* **1.9.x**                       (last tested: 1.9.15)
* **1.8.x**                       (last tested: 1.8.1)
* **1.7.x**                       (last tested: 1.7.10)
* **1.6.x**                       (last tested: 1.6.3)
* **1.5.x**
* **1.4.x**                       (last tested: 1.4.7)
* **1.3.x**
* **1.2.x**                       (last tested: 1.2.9)
* **1.1.x**
* **1.0.x**                       (last tested: 1.0.15

If you find that any particular version of Nginx does not work with this module, please consider [reporting a bug](#report-bugs).

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
You can see the changelist [from CHANGES file](CHANGES).

[Back to TOC](#table-of-contents)

Test Suite
==========

This module comes with a Perl-driven test suite. The [test cases](https://github.com/openresty/redis-nginx-module/tree/master/t/) are
[declarative](https://github.com/openresty/redis-nginx-module/blob/master/t/redis.t) too. Thanks to the [Test::Nginx](http://search.cpan.org/perldoc?Test::Nginx) module in the Perl world.

To run it on your side:

```bash

 $ PATH=/path/to/your/compiled-nginx-with-redis-module:$PATH prove -r t
```

You can also use the included `Makefile` to run tests in a docker containers:

```bash
$ make test
```

**Note:** The first installation takes quite some time (5-10min).

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
