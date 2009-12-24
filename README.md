Atomos
======

Atomos is an AtomPub Based minimal bloging engine implemented using Sinatra and DataMapper.

Features
--------

There are few features :-)

* Markdown (provided by Maruku)
* management of posts via Atom Publishing Protocol

Requirements
------------

	$ sudo gem install sinatra builder maruku do_sqlite3
	$ sudo gem install dm-core dm-validations dm-aggregates

Setup
-----

Edit `config.sample.yaml` and rename it to `config.yaml`.

Then:

	$ rackup

And see http://localhost:4567/

AtomPub
-------

Posts can be created using POST request to the Collection URI and edited using PUT request to the Member URI.

* Collection URI: {root}/atom/
* Member URI: {root}/atom/{year}/{month}/{day}/{slug}

If you use default templates without large modification, the following userscript offers means of these operation.

* http://gist.github.com/259339 (Firefox)
* http://gist.github.com/260425 (Chrome)

License
-------

MIT License

Copyright (C) 2009 Yasuhiro Fuse &lt;fuse@5ivestar.org&gt;
