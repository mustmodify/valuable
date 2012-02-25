require File.dirname(__FILE__) + '/phone_number'

class Person < Valuable
  has_value :name
  has_value :age, :klass => :integer
  has_value :phone_number, :klass => PhoneNumber
end

