require 'active_support'

class Valuable

  def attributes
    @attributes ||= HashWithIndifferentAccess.new(deep_duplicate_of(self.class.defaults)) 
  end

  def initialize(atts = {})
    atts.each { |name, value| __send__("#{name}=", value ) } 
  end

  def deep_duplicate_of(value)
    Marshal.load(Marshal.dump(value))
  end

  class << self

    def attributes
      @attributes ||= []
    end 

    def defaults
      @defaults ||= {}
    end 

    def has_value(name, options={})
      attributes << name 
      defaults[name] = options[:default] unless options[:default].nil?
      
      create_accessor_for(name)
      create_setter_for(name, options[:klass], options[:default])
    end

    def create_setter_for(name, klass, default)
        
      if klass == nil
        define_method "#{name}=" do |value|
          attributes[name] = value 
        end

      elsif klass == Integer

        define_method "#{name}=" do |value|
          value_as_integer = value && value.to_i
          attributes[name] = value_as_integer
        end

      elsif klass == String
	
	define_method "#{name}=" do |value|
          value_as_string = value && value.to_s
          attributes[name] = value_as_string
	end

      else

        define_method "#{name}=" do |value|
          if value.nil?
            attributes[name] = nil 
	  elsif value.is_a? klass
	    attributes[name] = value
	  else
	    attributes[name] = klass.new(value)
	  end
        end
      end
    end

    def create_accessor_for(name)
      define_method name do
        attributes[name]
      end
    end

    def has_collection(name)
      has_value(name, :default => [] )
    end 

  end

end
