#!/usr/bin/env rackup

$LOAD_PATH.unshift 'lib'

require 'rubygems'
require 'atomos'
require 'yaml'

opts = File.open('config.yaml') {|f| YAML.load(f) }
opts.update(:run => true)

run Atomos.new(opts)
