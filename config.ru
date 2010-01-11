#!/usr/bin/env rackup

$LOAD_PATH << 'lib'

require 'rubygems'
require 'atomos'
require 'yaml'

begin
  opts = YAML.load_file('config.yaml')
  run Atomos.new(opts)
rescue Errno::ENOENT
  run Atomos.new
end
