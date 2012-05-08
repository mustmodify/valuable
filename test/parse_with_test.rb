$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'valuable.rb'
require 'mocha'

class Person < Valuable
  has_value :first_name
  has_value :last_name

  def Person.load( name )
    f, l = name.split(' ') # trivial case
    new(:first_name => f, :last_name => l)
  end
end

class RailsApp < Valuable
  has_value :tech_lead, :klass => Person, :parse_with => :load
  has_collection :devs, :klass => Person, :parse_with => :load
  has_value :name, :parse_with => lambda{|x| x == 'IA' ? 'Information Architecture' : x}
  has_value :overlord, :klass => Person, :parse_with => lambda{|name| Person.load(name) }
end

class ParseWithTest < Test::Unit::TestCase
 
  def test_that_parse_with_calls_target_classes_parse_method
    ia = RailsApp.new(:tech_lead => 'Adam Dalton')
    assert_equal 'Adam', ia.tech_lead.first_name
  end

  def test_that_collections_are_parsed
    ia = RailsApp.new(:devs => ['Dennis Camp', 'Richard Hoblitzell', 'Paul Kuracz', 'Magda Lueiro', 'George Meyer', 'David Moyer', 'Bill Snoddy'])
    expected = ['Dennis', 'Richard', 'Paul', 'Magda', 'George', 'David', 'Bill']
    actual = ia.devs.map(&:first_name)
    assert_equal expected, actual
  end

  def test_that_lambdas_can_be_used_as_parsers
    assert_equal 'Information Architecture', RailsApp.new(:name => 'IA').name
  end

  def test_that_it_raises_an_error_when_passed_a_class_and_a_proc
    animal = Class.new(Valuable)
    assert_raises ArgumentError, "Class can't promise to return a(n) :integer when using the option :parse_with" do
      animal.has_value :invalid, :klass => :integer, :parse_with => :method
    end
  end

  def test_that_lambdas_can_be_combined_with_a_class
    assert_equal 'vader', RailsApp.new(:overlord => 'darth vader').overlord.last_name
  end
end
