Atomos
======

Atomos is an AtomPub Based minimal bloging engine implemented using Sinatra and DataMapper.

Features
--------

There are few features :-)

* Markdown (provided by RDiscount)
* management of posts via Atom Publishing Protocol

Requirements
------------

    $ sudo gem install sinatra haml builder rdiscount
    $ sudo gem install dm-core dm-migrations dm-validations dm-aggregates dm-sqlite-adapter

Setup
-----

Edit `config.sample.yaml` and rename it to `config.yaml`.

Then:

    $ rackup

And see http://localhost:9292/

AtomPub
-------

Posts can be created using POST request to the Collection URI and edited using PUT request to the Member URI.

* Collection URI: {root}/atom/
* Member URI: {root}/atom/{year}/{month}/{day}/{slug}

If you use default templates without large modification, the following userscript offers means of these operation.

* http://gist.github.com/259339

License
-------

MIT License

Copyright (c) 2010 Ryo Tanaka &lt;ryo@alpico.la&gt;
