# Valuable is the class from which all classes (who are so inclined)
# should inherit.
#
# ==Example:
# 
#   class Bus < Valuable
#     
#     has_value :number, :klass => :integer
#     has_value :color, :default => 'yellow'
#     has_collection :riders, :alias => 'Passengers'
#   
#   end
#
#   >> Bus.attributes
#   => [:number, :color, :riders]
#   >> bus = Bus.new(:number => '3', :Passengers => ['GOF', 'Fowler', 'Mort']
#   >> bus.attributes
#   => {:number => 3, :riders => ['GOF', 'Fowler', 'Mort'], :color => 'yellow'}
#   
class Valuable

  # Returns a Hash representing all known values. Values are set four ways:
  # 
  #   (1) Default values are set on instanciation, ie Person.new
  #   (2) they were passed to the constructor
  #          Bus.new(:color => 'green')
  #   (3) they were set via their namesake setter or alias setter
  #          bus.color = 'green'
  #          bus.Passengers = ['bill', 'steve']
  #   (4) the write_attributes(key, value) method
  # 
  # Values that have not been set and have no default not appear in this
  # collection. Their namesake attribute methods will respond with nil.
  # Always use symbols to access these values, ie:
  #   Person.attributes[:color]
  # not
  #   Person.attributes['color']
  #
  # basic usage: 
  #   >> bus = Bus.new(:number => 16) # color has default value 'yellow'
  #   >> bus.attributes
  #   => {:color => 'yellow', :number => 16}
  def attributes
    @attributes ||= Valuable::Utils.initial_copy_of_attributes(self.class.defaults) 
  end
  alias_method :initialize_attributes, :attributes 
  # alias is for readability in constructor

  # accepts an optional hash that will be used to populate the 
  # predefined attributes for this class.
  #
  # Note: You are free to overwrite the constructor, but you should call
  # initialize_attributes OR make sure at least one value is stored.
  def initialize(atts = nil)
    initialize_attributes
    self.update_attributes(atts || {})
  end

  # mass assign attributes. This method will not clear any existing attributes.
  #
  # class Shoe
  #   has_value :size
  #   has_value :owner
  #   has_value :color, :default => 'red'
  #
  #   def big_feet?
  #     size && size > 15
  #   end
  # end
  #
  # >> shoe = Shoe.new
  # >> shoe.update_attributes(:size => 16, :owner => 'MJ')
  # >> shoe.attributes
  # => {:size => 16, :owner => 'MJ', :color => 'red'}
  #
  # can be method-chained
  #
  # >> Shoe.new.update_attributes(:size => 16).big_feet?
  # => true
  def update_attributes(atts)
    atts.each{|name, value| __send__("#{name}=", value )}
    self
  end

  def permissive?
    self.class.permissive_constructor?
  end

  def method_missing(method_name, *args)
    if method_name.to_s =~ /(\w+)=/
      raise( ArgumentError, "#{self.class.to_s} does not have an attribute or alias '#{$1}'", caller) unless self.permissive?
    else
      super 
    end
  end

  def write_attribute(name, value)
    attribute = Valuable::Utils.find_attribute_for( name, self.class._attributes )

    if attribute
      self.attributes[attribute] = Valuable::Utils.format(attribute, value, self.class._attributes) 
    else
      raise( ArgumentError, "#{self.class.to_s} does not have an attribute or alias '#{name}'", caller) unless self.permissive?
    end
  end

  class << self

    # Returns an array of the attributes available on this object.
    def attributes
      _attributes.keys
    end 

    def _attributes
      @_attributes ||= {}
    end

    # Returns a name/value set of the values that will be used on
    # instanciation unless new values are provided.
    #
    #   >> Bus.defaults
    #   => {:color => 'yellow'}
    def defaults
      out = {}
      _attributes.each{|n, atts| out[n] = atts[:default] unless atts[:default].nil?}
      out
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
    #   :alias - creates an alias for getter and setter with the new name.
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
      Valuable::Utils.check_options_validity(self.class.name, name, options)

      options[:extend] = [options[:extend]].flatten.compact

      name = name.to_sym
      _attributes[name] = options 
     
      create_accessor_for(name, options[:extend])

      create_question_for(name) if options[:klass] == :boolean
      create_negative_question_for(name, options[:negative]) if options[:klass] == :boolean && options[:negative]
      
      create_setter_for(name)

      sudo_alias options[:alias], name if options[:alias]
      sudo_alias "#{options[:alias]}=", "#{name}=" if options[:alias]
    end

    # Creates the method that sets the value of an attribute.
    # The setter calls write_attribute, which handles typicification.
    # It is called by the constructor (rather than using
    # write attribute, which would render any custom setters
    # ineffective.)
    #
    # Setting values via the attributes hash avoids typification,
    # ie:
    # >> player.phone = "8778675309"
    # >> player.phone
    # => "(877) 867-5309"
    #
    # >> player.attributes[:phone] = "8778675309"
    # >> player.phone
    # => "8778675309"
    def create_setter_for(attribute)
      setter_method = "#{attribute}="

      define_method setter_method do |value|
        write_attribute(attribute, value)
      end

    end

    def sudo_alias( alias_name, method_name )
      define_method alias_name do |*atts|
        send(method_name, *atts)
      end
    end

    # creates an accessor method named after the 
    # attribute... can be used as a chained setter, 
    # as in:
    #
    #     whitehouse.windows(5).doors(4).oval_rooms(1)
    #
    # If NOT used as a setter, returns the value,
    # extended by the modules listed in the second 
    # parameter.
    def create_accessor_for(name, extensions)
      define_method name do |*args|
        if args.length == 0
          attributes[name].tap do |out|
            extensions.each do |extension|
              out.extend( extension )
            end
          end
        else
          send("#{name}=", *args)
          self
        end 
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
    #
    #   class Person
    #     has_collection :phone_numbers, :klass => PhoneNumber
    #   end
    #
    #   >> jenny = Person.new(:phone_numbers => ['8008675309'] )
    #   >> jenny.phone_numbers.first.class
    #   => PhoneNumber
    def has_collection(name, options = {})
      Utils.check_options_validity( self.class.name, name, options)
      name = name.to_sym
      options[:item_klass] = options[:klass] if options[:klass]
      options[:klass] = :collection
      options[:default] = []
      options[:extend] = [options[:extend]].flatten.compact

      _attributes[name] = options 
      
      create_accessor_for(name, options[:extend])
      create_setter_for(name)

      sudo_alias options[:alias], name if options[:alias]
      sudo_alias "#{options[:alias]}=", "#{name}=" if options[:alias]
    end 

    # Register custom formatters. Not happy with the default behavior?
    # Custom formatters override all pre-defined formatters. However,
    # remember that formatters are defined globally, rather than 
    # per-class.
    #
    # Valuable.register_formatter(:orientation) do |value|
    #   case value
    #   case Numeric
    #     value
    #   when 'N', 'North'
    #     0 
    #   when 'E', 'East'
    #     90 
    #   when 'S', 'South'
    #     180 
    #   when 'W', 'West'
    #     270 
    #   else
    #     nil 
    #   end
    # end
    #
    # class MarsRover < Valuable
    #   has_value :orientation, :klass => :orientation
    # end
    # 
    # >> curiosity = MarsRover.new(:orientation => 'S')
    # >> curiosity.orientation
    # => 180
    def register_formatter(name, &block)
      Valuable::Utils.formatters[name] = block
    end


    # Instructs the class NOT to complain if any attributes are set
    # that haven't been declared.
    #
    # class Sphere < Valuable
    #   has_value :material
    # end
    #
    # >> Sphere.new(:radius => 3, :material => 'water')
    # EXCEPTION! OH NOS!
    #
    # class Box < Valuable
    #   acts_as_permissive
    #
    #   has_value :material
    # end
    #
    # >> box = Box.new(:material => 'wood', :size => '36 x 40')
    # >> box.attributes
    # => {:material => 'wood'}
    def acts_as_permissive
      self.permissive_constructor=true
    end

    def permissive_constructor=(value)
      @_permissive_constructor = value
    end

    def permissive_constructor?
      !!(@_permissive_constructor ||= false)
    end

    private

    def inherited(child)
      _attributes.each {|n, atts| child._attributes[n] = atts }
    end
  end
end

require 'valuable/utils'
