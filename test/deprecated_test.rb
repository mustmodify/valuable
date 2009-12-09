$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'valuable.rb'
require 'mocha'

class Signature < String
end

class Cube < String
  def initialize(number)
    super "Lives in Cube #{number}"
  end
end

class DevCertifications < Valuable
  has_value :a_plus, :default => false
  has_value :mcts, :default => false
  has_value :hash_rocket, :default => false
end

class Dev < Valuable
  has_value :has_exposure_to_sunlight, :default => false
  has_value :mindset
  has_value :name, :default => 'DHH Jr.', :klass => String
  has_value :signature, :klass => Signature
  has_value :cubical, :klass => Cube
  has_value :hacker, :default => true
  has_value :certifications, :default => DevCertifications.new
  has_value :quote

  has_collection :favorite_gems  

end

# Previously, we used :klass => Klass instead of :klass => :klass.
# I decided it was just plain dirty. On refactoring, I realized that
# most it would continue to work. Other stuff, unfortunately, would
# break horribly. (Integer.new, for instance, makes Ruby very angry.)
# The purpose of these tests is to verify that everything _either_ 
# breaks horribly or works, where the third option is fails silently
# and mysteriously.
class DeprecatedTest < Test::Unit::TestCase
  
  def test_that_attributes_can_be_klassified
    dev = Dev.new(:signature => 'brah brah')
    assert_equal Signature, dev.signature.class
  end

  def test_that_randomly_classed_attributes_persist_nils
    assert_equal nil, Dev.new.signature
  end

  def test_that_randomly_classed_attributes_respect_defaults
    assert_equal 'DHH Jr.', Dev.new.name
  end

  def test_that_constructor_casts_attributes
    assert_equal 'Lives in Cube 20', Dev.new(:cubical => 20).cubical
  end

  def test_that_setter_casts_attributes
    golden_boy = Dev.new
    golden_boy.cubical = 20
    
    assert_equal 'Lives in Cube 20', golden_boy.cubical
  end

  def test_that_properly_klassed_values_are_not_rekast
    why_hammer = Signature.new('go ask your mom')
    Signature.expects(:new).with(why_hammer).never
    hammer = Dev.new(:signature => why_hammer)
  end

  def test_that_default_values_can_be_set_to_nothing
    assert_equal nil, Dev.new(:hacker => nil).hacker
  end

end

