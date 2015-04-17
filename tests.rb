#!/usr/bin/env ruby
require_relative 'Bootstrap'
require 'coveralls'
require 'RubyUnit'

Coveralls.wear!

require_relative 'tests/signer_test.rb'
