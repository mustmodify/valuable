$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'valuable.rb'

class Developer < Valuable
  has_value :name, :klass => :string
end

class YamlTest < Test::Unit::TestCase

  
end
