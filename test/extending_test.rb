$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'valuable.rb'

module BookCollection
end

module PirateFormatter
  def to_pirate
    "#{self}, ARRRGGGhhhhh!"
  end
end

class Series < Valuable
  has_collection :books, :extend => BookCollection
  has_value :name, :extend => PirateFormatter
end

class ExtendingTest < Test::Unit::TestCase
  def test_that_collections_are_extended
    assert Series.new.books.is_a?(BookCollection)
  end

  def test_that_values_are_extended
    assert_equal 'Walk The Plank, ARRRGGGhhhhh!', Series.new(:name => 'Walk The Plank').name.to_pirate
  end

end

