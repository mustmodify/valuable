$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'valuable.rb'

class Beer < Valuable
  has_value :name
  has_value :brewery
end

class WriteAndReadAttributeTest < Test::Unit::TestCase

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

  def test_that_values_can_be_set_using_newfangled_way
    beer = Beer.new
    beer.name('Abita Amber')
    assert_equal 'Abita Amber', beer.name
  end

  def test_newfangled_fluid_chaining
    beer = Beer.new
    beer.name('Amber').brewery('Abita')
    assert_equal 'Abita', beer.brewery
  end

end

