#! /usr/bin/env ruby

require_relative 'bootstrap'
require 'coveralls'
require "codeclimate-test-reporter"
require 'scrutinizer/ocular'
require 'RubyUnit'

Coveralls.wear!
CodeClimate::TestReporter.start
Scrutinizer::Ocular.watch!
SimpleCov.command_name 'Unit Tests'

require_relative 'tests/signer_test.rb'
