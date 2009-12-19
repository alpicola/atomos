require 'dm-core'

require 'atomos/entry'
require 'atomos/application'

module Atomos
	def self.configure(&block)
		Application.class_eval(&block)
	end

	def self.new(&block)
		configure(&block) if block_given?

		DataMapper.setup(:default, Application.database)
		DataMapper.auto_upgrade!

		Application
	end
end
