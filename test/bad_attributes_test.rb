$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'valuable.rb'
require 'mocha'

class Infrastructure < Valuable
end

class BadAttributesTest < Test::Unit::TestCase

  def test_that_has_value_grumbles_when_it_gets_bad_attributes
    assert_raises ArgumentError do
      Infrastructure.has_value :fu, :invalid => 'shut your mouth'
    end
  end

  def test_that_valid_arguments_cause_no_grumbling
    assert_nothing_raised do
      Infrastructure.has_value :bar, :klass => Integer
    end
  end
end
