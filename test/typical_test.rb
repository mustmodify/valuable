$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'valuable.rb'
require 'date'
require File.dirname(__FILE__) + '/../examples/phone_number'
class Person < Valuable
  has_value :dob, :klass => :date
end

class TypicalTest < Test::Unit::TestCase

  def test_that_dates_can_be_set_directly
    born_on = Date.civil(1976, 07, 26)
    me = Person.new( :dob => born_on )
    assert_equal( born_on, me.dob )
  end

  def test_that_dates_are_parsed_from_strings
    neil_born_on = 'August 5, 1930'
    neil = Person.new( :dob => neil_born_on )
    assert_equal( Date.civil( 1930, 8, 5 ), neil.dob )
  end

  def test_that_a_date_might_not_be_set_yet_and_that_can_be_ok
    dr_who = Person.new( :dob => nil )
    assert_nil( dr_who.dob )
  end

  def test_that_collections_are_typified
    people = Class.new(Valuable)
    people.has_collection( :phones, :klass => PhoneNumber )

    person = people.new(:phones => ['8668675309'])
    assert_kind_of( Array, person.phones )
    assert_kind_of( PhoneNumber, person.phones.first )
  end

  def test_that_it_discovers_an_invalid_klass
    animal = Class.new(Valuable)
    assert_raises ArgumentError, "Animal doesn't know how to format species with :klass => 'invalid'" do
      animal.has_value :species, :klass => :invalid
    end
  end

  def test_that_decimals_typified
    chemical = Class.new(Valuable)
    chemical.has_value :ph, :klass => :decimal
    lemon_juice = chemical.new(:ph => 1.8)
    assert_kind_of BigDecimal, lemon_juice.ph
  end
end

