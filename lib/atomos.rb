require 'atomos/application'
require 'atomos/models'

module Atomos
  VERSION = '0.2.1'.freeze

  def self.configure(opts={})
    DataMapper.setup(:default, opts[:database] || ENV['DATABASE_URL'])
    DataMapper.auto_migrate!

    Application.set(opts)
  end

  def self.new(opts={})
    configure(opts)

    Application
  end
end
