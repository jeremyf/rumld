require 'forwardable'
require 'rubygems'
gem 'hpricot'

require 'hpricot'
require 'mocha'

unless defined? RAILS_ENV
  gem 'activesupport'
  require 'active_support/core_ext/string'
end

module Rumld
end

require File.join(File.dirname(__FILE__), 'rumld','graph')
require File.join(File.dirname(__FILE__), 'rumld','tree')
require File.join(File.dirname(__FILE__), 'rumld','node')
require File.join(File.dirname(__FILE__), 'rumld','rdoc_inspector')
