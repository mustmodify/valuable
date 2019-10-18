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

  def test_that_we_provide_a_better_error_when_objects_can_not_be_marhsaled
    assert_raises ArgumentError do
      Class.new(Valuable) do
        has_value :invalid, :default => StringIO.new
      end
    end
  end

  def test_that_Strings_are_not_numbers
    player = Class.new(Valuable) do
      has_value :number, :klass => :integer
    end

    assert_equal nil, player.new(number: 'abc').number
  end
end

