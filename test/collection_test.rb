$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'valuable.rb'
require 'mocha/setup'

class Album < Valuable
  has_collection :concepts, default: -> {['a', 'b', 'c']}
end

class BaseTest < Test::Unit::TestCase
  def test_that_collection_can_have_a_default_value
    album = Album.new
    assert_equal ['a', 'b', 'c'], album.concepts
  end
end
