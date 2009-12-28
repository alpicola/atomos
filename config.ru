#!/usr/bin/env rackup

$LOAD_PATH << 'lib'

require 'rubygems'
require 'atomos'
require 'yaml'

begin
	opts = File.open('config.yaml') {|f| YAML.load(f) }
	run Atomos.new(opts)
rescue Errno::ENOENT
	run Atomos.new
end
