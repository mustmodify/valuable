# Valuable is the class from which all classes (who are so inclined)
# should inherit.
#
# ==Example:
# 
#   class Bus < Valuable
#     
#     has_value :number, :klass => :integer
#     has_value :color, :default => 'yellow'
#     has_collection :riders
#   
#   end
#
#   >> Bus.attributes
#   => [:number, :color, :riders]
#   >> bus = Bus.new(:number => '3', :riders => ['GOF', 'Fowler', 'Mort']
#   >> bus.attributes
#   => {:number => 3, :riders => ['GOF', 'Fowler', 'Mort'], :color => 'yellow'}
class Valuable

  # Returns a Hash representing all known values. Values are set three ways:
  # 
  #   (1) a default value
  #   (2) they were passed to the constructor
  #          Bus.new(:color => 'green')
  #   (3) they were set via their namesake setter
  #          bus.color = 'green'
  #          
  # Values that have not been set and have no default not appear in this
  # collection. Their namesake attribute methods will respond with nil.
  # Always use symbols to access these values.
  # 
  #   >> bus = Bus.new(:number => 16) # color has default value 'yellow'
  #   >> bus.attributes
  #   => {:color => 'yellow', :number => 16}
  def attributes
    @attributes ||= deep_duplicate_of(self.class.defaults) 
  end

  # accepts an optional hash that will be used to populate the 
  # predefined attributes for this class.
  def initialize(atts = nil)
    atts.each { |name, value| __send__("#{name}=", value ) }  if atts
  end

  def deep_duplicate_of(value)
    Marshal.load(Marshal.dump(value))
  end

  class << self

    # Returns an array of the attributes available on this object.
    def attributes
      @attributes ||= []
    end 

    # Returns a name/value set of the values that will be used on
    # instanciation unless new values are provided.
    #
    #   >> Bus.defaults
    #   => {:color => 'yellow'}
    def defaults
      @defaults ||= {}
    end 

    # Decorator method that lets you specify the attributes for your
    # model. It accepts an attribute name (a symbol) and an options 
    # hash. Valid options are :default, :klass and (when :klass is 
    # Boolean) :negative.
    #
    #   :default - for the given attribute, use this value if no other
    #   is provided.
    #
    #   :klass - light weight type casting. Use :integer, :string or
    #   :boolean. Alternately, supply a class. 
    #
    # When a :klassified attribute is set to some new value, if the value
    # is not nil and is not already of that class, the value will be cast
    # to the specified klass. In the case of :integer, it wil be done via
    # .to_i. In the case of a random other class, it will be done via
    # Class.new(value). If the value is nil, it will not be cast.
    #
    # A good example: PhoneNumber < String is useful if you
    # want numbers to come out the other end properly formatted, when your
    # input may come in as an integer, or string without formatting, or
    # string with bad formatting.
    # 
    # IMPORTANT EXCEPTION
    #
    # Due to the way Rails handles checkboxes, '0' resolves to FALSE,
    # though it would normally resolve to TRUE.
    def has_value(name, options={})

      name = name.to_sym
      
      attributes << name
      
      defaults[name] = options[:default] unless options[:default].nil?
      
      create_accessor_for(name)
      create_question_for(name) if options[:klass] == :boolean
      create_negative_question_for(name, options[:negative]) if options[:klass] == :boolean && options[:negative]
      
      create_setter_for(name, options[:klass], options[:default])

      check_options_validity(name, options)
    end

    # Creates the method that sets the value of an attribute. This setter
    # is called both by the constructor. The constructor handles type
    # casting. Setting values via the attributes hash avoids the method
    # defined here.
    def create_setter_for(name, klass, default)

      case klass
      when NilClass
	      
        define_method "#{name}=" do |value|
          attributes[name] = value 
        end

      when :integer

        define_method "#{name}=" do |value|
          value_as_integer = value && value.to_i
          attributes[name] = value_as_integer
        end

      when :string
	
	define_method "#{name}=" do |value|
          value_as_string = value && value.to_s
          attributes[name] = value_as_string
	end

      when :boolean

        define_method "#{name}=" do |value|
          attributes[name] = value == '0' ? false : !!value
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

    # creates a simple accessor method named after the attribute whose
    # value it will provide during the life of the instance.
    def create_accessor_for(name)
      define_method name do
        attributes[name]
      end
    end

    # In addition to the normal getter and setter, boolean attributes
    # get a method appended with a ?.
    #
    #   class Player < Valuable
    #     has_value :free_agent, :klass => Boolean
    #   end
    #
    #   juan = Player.new(:free_agent => true)
    #   >> juan.free_agent?
    #   => true
    def create_question_for(name)
      define_method "#{name}?" do
        attributes[name]
      end
    end

    # In some situations, the opposite of a value may be just as interesting.
    #
    #   class Coder < Valuable
    #     has_value :agilist, :klass => Boolean, :negative => :waterfaller
    #   end
    #
    #   monkey = Coder.new(:agilist => false)
    #   >> monkey.waterfaller?
    #   => true
    def create_negative_question_for(name, negative)
      define_method "#{negative}?" do
        !attributes[name]
      end
    end

    # this is a more intuitive way of marking an attribute as holding a
    # collection. 
    #
    #   class Bus < Valuable
    #     has_value :riders, :default => [] # meh...
    #     has_collection :riders # better!
    #   end
    #
    #   >> bus = Bus.new
    #   >> bus.riders << 'jack'
    #   >> bus.riders
    #   => ['jack']
    def has_collection(name)
      has_value(name, :default => [] )
    end 

    private

    def inherited(child)
      attributes.each {|att| child.attributes << att }
      defaults.each {|(name, value)| child.defaults[name] = value }
    end
    
    def known_options
     [:klass, :default, :negative]
    end

    # this helper raises an exception if the options passed to has_value
    # are wrong. Mostly written because I occasionally used :class instead
    # of :klass and, being a moron, wasted time trying to find the issue. 
    def check_options_validity(name, options)
      invalid_options = options.keys - known_options 

      raise ArgumentError, "has_value did not know how to respond to option(s) #{invalid_options.join(', ')}. Valid (optional) arguments are: #{known_options.join(', ')}" unless invalid_options.empty?      
    end

  end

end
