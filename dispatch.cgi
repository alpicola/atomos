#!/usr/bin/env ruby

$LOAD_PATH << 'lib'

require 'rubygems'
require 'atomos'
require 'yaml'

ENV['PATH_INFO'] = '/' if ENV['PATH_INFO'].to_s.empty?

begin
  opts = YAML.load_file('config.yaml')
  Rack::Handler::CGI.run Atomos.new(opts)
rescue Errno::ENOENT
  Rack::Handler::CGI.run Atomos.new
end
