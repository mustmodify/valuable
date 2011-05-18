class PhoneNumber < String
  def initialize(value)
    super(value.to_s)
  end

  def valid?
    has_ten_digits?  
  end
  
  def has_ten_digits?
    self =~ /\d{9}/
  end

  def inspect
    self.to_s
  end
  
  def to_s
    "(#{self[0..2]}) #{self[3..5]}-#{self[6..9]}" if valid?
  end
end
