#! /usr/bin/env ruby

require_relative 'bootstrap'
require 'coveralls'
require 'scrutinizer/ocular'
require 'RubyUnit'
require 'simplecov'

Coveralls.wear!
Scrutinizer::Ocular.watch!
SimpleCov.start
SimpleCov.command_name 'Unit Tests'

require_relative 'tests/signer_test.rb'
