$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'valuable.rb'

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

  def test_that_invalid_attributes_raise
    assert_raises ArgumentError do
      model = Class.new(Valuable)
      model.new(:invalid => 'should not be allowed')
    end
  end

  def test_that_invalid_attributes_can_be_ignored
    assert_nothing_raised do
      model = Class.new(Valuable) do
        acts_as_permissive 
      end
      model.new(:invalid => 'should be ignored')
    end
  end
end

