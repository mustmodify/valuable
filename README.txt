
=Introducing Valuable

Valuable enables quick modeling... is attr_accessor on steroids.  It intends to use a simple and intuitive interface, allowing you easily create models without hassles, so you can get on with the logic specific to your application.

Valuable provides DRY decoration like attr_accessor, but includes default values, light weight type casting and a constructor that accepts an attributes hash. It provides a class-level list of attributes, an instance-level attributes hash, and more.

==Example
<code>
class BaseballPlayer < Valuable

  has_value :at_bats, :klass => :integer
  has_value :hits, :klass => :integer

  def average
    hits/at_bats.to_f if hits && at_bats
  end
end

>> joe = BaseballPlayer.new(:hits => '5', :at_bats => '20')

>> joe.at_bats
=> 20

>> joe.average
=> 0.25

class School < Valuable
  has_value :name
  has_value :phone, :klass => PhoneNumber
  has_value :location, :default => 'unknown'
end

>> school = School.new(:name => 'Vanderbilt', :phone => '3332223333')

>> school.location
=> 'unknown'

>> school.location = nil

>> school.location
=> nil

>> school.phone
=> '(333) 222-3333'
</code>

==DEFAULT VALUES

Default values are used when no value is provided to the constructor. If the value nil is provided, nil will be used instead of the default. 

When a default value and a klass are specified, the default value will NOT be cast to type klass -- you must do it.

If a value having a default is set to null after it is constructed, it will NOT be set to the default.

If there is no default value, the result will be nil, EVEN if type casting is provided. Thus, a field typically cast as an Integer can be nil. See calculation of average.

==KLASS-ification

:integer, :string and :boolean use to_i, to_s and !! respectively. All other klasses use klass.new(value) unless the value is_a(klass), in which case it is unmolested. Nils are never klassified. In the example above, hits, which is an integer, is nil if not set, rather than nil.to_i = 0.
