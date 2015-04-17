#! /usr/bin/env ruby

require_relative 'bootstrap'
require 'coveralls'
require "codeclimate-test-reporter"
require 'RubyUnit'

Coveralls.wear!
CodeClimate::TestReporter.start

require_relative 'tests/signer_test.rb'
