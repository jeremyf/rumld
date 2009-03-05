$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../lib'))
require "test/unit"
require 'rumld'

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
