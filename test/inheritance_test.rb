$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'test/unit'
require 'valuable.rb'
require 'mocha'

class Parent < Valuable
  has_value :name, :default => 'unknown'
end

class Child < Parent
  has_value :age
end

class InheritanceTest < Test::Unit::TestCase

  def test_that_children_inherit_their_parents_attributes
    assert Child.attributes.include?(:name)
  end	  

  def test_that_children_have_distinctive_attributes
    assert Child.attributes.include?(:age)
  end

  def test_that_parents_do_not_inherit_things_from_children
    assert_equal [:name], Parent.attributes
  end
end
