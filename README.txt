=Introducing Valuable=

Valuable is a ruby base class that is essentially attr_accessor on steroids. Its aim is to provide Rails-like goodness where ActiveRecord isn't an option.  It intends to use a simple and intuitive interface, allowing you to get on with the logic specific to your application.

Valuable provides the same dry declaration as attr_accessor, but includes default values, light weight type casting, a constructor that accepts an attributes hash, a class-level list of attributes, and an instance-level attributes hash. The type casting can also be used for parsing values.

==Example==

{{{
class BaseballPlayer < Valuable

  has_value :at_bats, :klass => Integer
  has_value :hits, :klass => Integer
  has_value :league, :default => 'unknown'
  has_value :name
  has_value :jersey, :klass => Jersey, :default => 'Unknown'

  has_collection :teammates

  def average
    hits/at_bats.to_f if hits && at_bats
  end
end

class Jersey < String
  def initialize(object)
    super "Jersey Number #{object})"
  end
end

>> joe = BaseballPlayer.new(:name => 'Joe', :hits => 5, :at_bats => 20, :jersey => 12)
>> joe.at_bats
=> 20
>> joe.league
=> 'unknown'
>> joe.average
=> 0.25
>> joe.at_bats = nil
>> joe.average
=> nil
>> joe.teammates
=> []
>> joe.jersey
=> 'Jersey Number 12'
>> joe.jersey = nil
>> joe.jersey
=> 'Unknown' 
}}}

==DEFAULT VALUES==

Default values are used when the attribute is nil. When a default value and a klass are specified, the default value will NOT be cast to type klass -- you must do it.

If there is no default value, the result will be nil, EVEN if type casting is provided. Thus, a field typically cast as an Integer can be nil. See calculation of average.

==KLASS-ification==

Integer and String use to_i and to_s, respectively. All other klasses use klass.new(value). Nils are never klassified. In the example above, hits, which is an integer, is nil if not set, rather than nil.to_i = 0.
