$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'test/unit'
require 'valuable.rb'
require 'mocha'

class Person < Valuable
  has_value :first_name
  has_value :last_name

  def initialize(atts={})
    self.first_name = "Joe"
    super(atts)
  end
end

class ParseWithTest < Test::Unit::TestCase
 
  def test_that_attributes_are_accessible_in_custom_constructor
    assert_nothing_raised do
      Person.new(:last_name => 'Smith')
    end
  end
end

