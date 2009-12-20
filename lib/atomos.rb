require 'dm-core'

require 'atomos/application'
require 'atomos/entry'

module Atomos
	def self.new(opts={})
		DataMapper.setup(:default, opts[:database] || ENV['DATABASE_URL'])
		DataMapper.auto_upgrade!

		Application.set(opts)
		Application
	end
end
