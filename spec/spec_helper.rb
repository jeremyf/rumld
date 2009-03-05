## This file is copied to ~/spec when you run 'ruby script/generate rspec'
## from the project root directory.
#ENV["RAILS_ENV"] = "test"
#require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
#require 'spec/rails'
#
#Spec::Runner.configure do |config|
#  config.use_transactional_fixtures = true
#  config.use_instantiated_fixtures  = false
#  config.fixture_path = RAILS_ROOT + '/spec/fixtures'
#
#  # You can declare fixtures for each behaviour like this:
#  #   describe "...." do
#  #     fixtures :table_a, :table_b
#  #
#  # Alternatively, if you prefer to declare them only once, you can
#  # do so here, like so ...
#  #
#  #   config.global_fixtures = :table_a, :table_b
#  #
#  # If you declare global fixtures, be aware that they will be declared
#  # for all of your examples, even those that don't use them.
#end
#
require 'stringio'
require 'rbconfig'

dir = File.dirname(__FILE__)
lib_path = File.expand_path("#{dir}/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
$_spec_spec = true # Prevents Kernel.exit in various places

require 'rumld'
gem 'rspec'
require 'spec'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

class << ActiveRecord::Base
  def columns
    [:id].collect{|i| ActiveRecord::ConnectionAdapters::Column.new(i, nil)}
  end
end

module Abstract; end
class FirstAbstractUnit < ActiveRecord::Base
  include Abstract
  has_many :second_abstract_units
  has_one :primary_abstract_unit, :class_name => 'SecondAbstractUnit'
end

class SecondAbstractUnit < ActiveRecord::Base
  include Abstract
  
  belongs_to :first_abstract_unit
end

class ThirdAbstractUnit < ActiveRecord::Base
  belongs_to :stuff, :polymorphic => true
end

class FourthAbstractUnit < ActiveRecord::Base
  has_many :third_abstract_units, :as => :stuff
end

class String
  def no_whitespace
    gsub(/(\ |\n|\r)/, '')
  end
end

class Nil
  def no_whitespace
    self
  end
end
