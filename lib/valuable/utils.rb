module Valuable::Utils
  class << self

    def deep_duplicate_of(value)
      Marshal.load(Marshal.dump(value))
    end


  end
end

