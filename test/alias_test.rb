$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'valuable.rb'

class Software < Valuable
  has_value :name, :alias => :title
  has_value :enterprise_namespace, :alias => 'EnterpriseNamespace'
end

class AliasTest < Test::Unit::TestCase

  def test_that_values_can_be_set_using_their_alias
    software = Software.new(:title => 'PostIt')
    assert_equal 'PostIt', software.name
  end

  def test_that_aliases_can_be_strings
    software = Software.new('EnterpriseNamespace' => 'Enterprisey')
    assert_equal 'Enterprisey', software.enterprise_namespace
  end

  def test_that_aliases_work_for_getters
    software = Software.new(:title => 'ObtrusiveJavascriptComponent')
    assert_equal 'ObtrusiveJavascriptComponent', software.name
  end
end
