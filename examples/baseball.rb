class Jersey < String
  def initialize(object)
    super "Jersey Number #{object})"
  end
end

class BaseballPlayer < Valuable

  has_value :at_bats, :klass => Integer
  has_value :hits, :klass => Integer
  has_value :league, :default => 'unknown'
  has_value :name
  has_value :jersey, :klass => Jersey, :default => 'Unknown'
  has_value :active, :klass => Boolean
  
  has_collection :teammates

  def average
    hits/at_bats.to_f if hits && at_bats
  end
end
