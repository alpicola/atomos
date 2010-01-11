require 'atomos/application'
require 'atomos/entry'

module Atomos
  VERSION = '0.1.1'

  def self.configure(opts={})
    DataMapper.setup(:default, opts[:database] || ENV['DATABASE_URL'])
    DataMapper.auto_upgrade!

    Application.set(opts)
  end

  def self.new(opts={})
    configure(opts)

    Application
  end
end
