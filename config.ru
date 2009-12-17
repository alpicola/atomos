$LOAD_PATH.unshift 'lib'

require 'rubygems'
require 'atomos'

Atomos::Application.configure do |app|
	app.instance_eval do
		set :root,   File.dirname(__FILE__)
		set :run,    true
		set :static, true

		# configuration
		set :url,    'http://localhost:9393'
		set :title,  'Atomos Blog'
		set :author, 'Anonymous'

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
end

run Atomos::Application
