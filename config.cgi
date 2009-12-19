#!/usr/bin/env ruby

$LOAD_PATH.unshift 'lib'

require 'rubygems'
require 'atomos'

Atomos.configure do
	set :run, false

	set :url,    'http://localhost:4567'
	set :title,  'Atomos Blog'
	set :author, 'Anonymous'

	# specify your data-store as URL
	# set :database, ENV['DATABASE_URL']

	# the number of entries rendered per page
	set :per_page, 10

	# use a timezone different from the server
	# set :timezone, '+09:00'

	# parameters used in Digest Authorization
	# password_digest is a value of
	#   Digest::MD5.hexdigest(username + ':' + realm + ':' + password)
	# private_key is an arbitrary string known only to the server
	set :username,        'admin'
	set :realm,           'Atomos'
	set :password_digest, ''
	set :private_key,     ''
end

ENV['PATH_INFO'] = '/' if ENV['PATH_INFO'].to_s.empty?

Rack::Handler::CGI.run Atomos.new
