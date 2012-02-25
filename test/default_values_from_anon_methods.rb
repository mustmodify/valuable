$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'test/unit'
require 'valuable.rb'

class Borg < Valuable
  class << self
    attr_accessor :count
  end
  has_value :position, :default => lambda { Borg.count += 1 } 
  has_value :name

  def designation
    "#{self.position} of #{Borg.count}"
  end
end

class DefaultValueFromAnonMethodsTest < Test::Unit::TestCase

  def test_that_children_inherit_their_parents_attributes
    Borg.count = 6
    seven = Borg.new
    Borg.count = 9
    assert_equal '7 of 9', seven.designation  
  end	  

end

