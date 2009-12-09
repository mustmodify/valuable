$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'valuable.rb'
require 'mocha'

class Signature < String
end

class Cubical < String
  def initialize(number)
    super "Lives in Cubical #{number}"
  end
end

class DevCertifications < Valuable
  has_value :a_plus, :default => false
  has_value :mcts, :default => false
  has_value :hash_rocket, :default => false
end

class Developer < Valuable
  has_value :experience, :klass => Integer
  has_value :has_exposure_to_sunlight, :default => false
  has_value :mindset
  has_value :name, :default => 'DHH Jr.', :klass => String
  has_value :signature, :klass => Signature
  has_value :snacks_per_day, :klass => Integer, :default => 7
  has_value :cubical, :klass => Cubical
  has_value :hacker, :default => true
  has_value :certifications, :default => DevCertifications.new
  has_value :quote

  has_collection :favorite_gems  

end

class BaseTest < Test::Unit::TestCase
 
  def test_that_an_attributes_hash_is_available
    assert_kind_of(Hash, Developer.new.attributes)
  end

  def test_that_static_defaults_hash_is_available  
    assert_equal 'DHH Jr.', Developer.defaults[:name]
  end
  
  def test_that_an_accessor_is_created
    dev = Developer.new(:mindset => :agile)
    assert_equal :agile, dev.mindset
  end
  
  def test_that_setter_is_created
    dev = Developer.new
    dev.mindset = :enterprisey
    assert_equal :enterprisey, dev.mindset
  end
  
  def test_that_attributes_can_be_cast_as_integer
    dev = Developer.new(:experience => 9.2)
    assert_equal 9, dev.experience
  end
  
  def test_that_integer_attributes_respect_default
    assert_equal 7, Developer.new.snacks_per_day
  end

  def test_that_an_integer_attribute_with_no_value_results_in_nil
    assert_equal nil, Developer.new.experience
  end

  def test_that_attributes_can_be_klassified
    dev = Developer.new(:signature => 'brah brah')
    assert_equal Signature, dev.signature.class
  end

  def test_that_defaults_appear_in_attributes_hash
    assert_equal false, Developer.new.attributes[:has_exposure_to_sunlight]
  end
  
  def test_that_attributes_can_have_default_values
    assert_equal false, Developer.new.has_exposure_to_sunlight
  end

  def test_that_randomly_classed_attributes_persist_nils
    assert_equal nil, Developer.new.signature
  end

  def test_that_randomly_classed_attributes_respect_defaults
    assert_equal 'DHH Jr.', Developer.new.name
  end

  def test_that_constructor_casts_attributes
    assert_equal 'Lives in Cubical 20', Developer.new(:cubical => 20).cubical
  end

  def test_that_setter_casts_attributes
    golden_boy = Developer.new
    golden_boy.cubical = 20
    
    assert_equal 'Lives in Cubical 20', golden_boy.cubical
  end
  
  def test_that_attributes_are_available_as_class_method
    assert Developer.attributes.include?(:signature)
  end

  def test_that_a_model_can_have_a_collection
    assert_equal [], Developer.new.favorite_gems
  end

  def test_that_values_do_not_mysteriously_jump_instances
    panda = Developer.new
    panda.mindset = 'geek'

    hammer = Developer.new
    
    assert_not_equal 'geek', hammer.mindset
  end
  
  def test_that_collection_values_do_not_roll_across_instances
    jim = Developer.new
    jim.favorite_gems << 'Ruby'

    clark = Developer.new

    assert_equal [], clark.favorite_gems
  end

  def test_that_attributes_are_cast
    panda = Developer.new(:name => 'Code Panda', :experience => '8')
    assert_kind_of Integer, panda.attributes[:experience]
  end

  def test_that_stringy_keys_are_tried_in_absence_of_symbolic_keys
    homer = Developer.new('quote' => "D'oh!")
    assert_equal "D'oh!", homer.quote 
  end

  def test_that_default_values_from_seperate_instances_are_not_references_to_the_default_value_for_that_field
    assert_not_equal Developer.new.favorite_gems.object_id, Developer.new.favorite_gems.object_id
  end

  def test_that_properly_klassed_values_are_not_rekast
    why_hammer = Signature.new('go ask your mom')
    Signature.expects(:new).with(why_hammer).never
    hammer = Developer.new(:signature => why_hammer)
  end

  def test_that_values_can_be_set_to_false
    assert_equal false, Developer.new(:hacker => false).hacker
  end

  def test_that_default_values_needing_deep_duplication_get_it
    a = Developer.new
    b = Developer.new

    a.certifications.hash_rocket = true
    assert_equal false, b.certifications.hash_rocket    
  end

  def test_that_default_values_can_be_set_to_nothing
    assert_equal nil, Developer.new(:hacker => nil).hacker
  end
end
