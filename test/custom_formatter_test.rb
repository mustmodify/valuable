$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'valuable.rb'

Valuable.register_formatter(:point) do |latitude, longitude|
  :perfect
end

Valuable.register_formatter(:temperature) do |input|
  if input.nil?
    'unknown'
  else
    'very hot'
  end
end

class MarsLander < Valuable 
  has_value :position, :klass => :point
  has_value :core_temperature, :klass => :temperature
end

class CustomFormatterTest < Test::Unit::TestCase

  def test_that_formatter_keys_are_added_to_the_klass_options_list
    assert Valuable::Utils.klass_options.include?( :point )
  end
 
  def test_that_custom_formatters_are_used_to_set_attributes
    expected = :perfect
    actual = MarsLander.new(:position => [10, 20]).position
    assert_equal expected, actual
  end

  def test_that_nil_values_are_not_passed_to_custom_formatter
    expected = nil
    actual = MarsLander.new(:core_temperature => nil).core_temperature
    assert_equal expected, actual
  end
end

