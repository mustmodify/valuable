$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'valuable.rb'

class Beer < Valuable
  has_value :name
end

class AliasTest < Test::Unit::TestCase

  def test_that_values_can_be_set_using_write_attribute
    beer = Beer.new
    beer.write_attribute(:name, 'Red Stripe')
    assert_equal 'Red Stripe', beer.name
  end

  def test_that_values_can_be_set_using_stringified_attribute
    beer = Beer.new
    beer.write_attribute('name', 'Fosters')
    assert_equal 'Fosters', beer.name
  end
end

