# Trying to extract as much logic as possible to minimize the memory
# footprint of individual instances. Feedback welcome.
require 'bigdecimal'

module Valuable::Utils
  class << self

    def find_attribute_for( name, attributes )
      name = name.to_sym

      if attributes.keys.include?( name )
        name
      elsif found=attributes.find{|n, v| v[:alias].to_sym == name }
        found[0]
      end
    end

    def initial_copy_of_attributes(atts)
      out = {}
      atts.each do |name, value|
        case value
        when Proc
          out[name] = value.call
        else
          out[name] = deep_duplicate_of( value )
        end
      end

      out
    end

    def deep_duplicate_of(value)
      Marshal.load(Marshal.dump(value))
    end

    def format( name, value, attributes, collection_item = false )
      klass = collection_item ? attributes[name][:item_klass] : attributes[name][:klass]

      case klass
      when *formatters.keys 
        formatters[klass].call(value)

      when NilClass

        if Proc === attributes[name][:parse_with]
          attributes[name][:parse_with].call(value)
        else
          value
        end

      when :collection
        if( value.kind_of?(Array) )
          out = value.map do |item|
            Valuable::Utils.format( name, item, attributes, true )
          end
        end

      when :date

        case value.class.to_s
        when "Date"
          value
        when "ActiveSupport::TimeWithZone", "Time", "DateTime"
          value.to_date
        when "String"
          value && DateTime.parse(value)
        else
          value
        end

      when :integer

        value.to_i if value && value != ''

      when :decimal

        case value
        when NilClass
          nil
        when BigDecimal
          value
        else
          BigDecimal.new( value.to_s )
        end
  
      when :string
        
        value && value.to_s

      when :boolean

        value == '0' ? false : !!value
      
      else

        if value.nil?
          nil
        elsif value.is_a? klass
          value
        elsif Proc === attributes[name][:parse_with]
          attributes[name][:parse_with].call(value)
        else
          klass.send( attributes[name][:parse_with] || :new, value)
        end

      end unless value.nil?

    end
   
    def formatters
      @formatters ||= {}
    end
 
    def klass_options
      [NilClass, :integer, Class, :date, :decimal, :string, :boolean] + formatters.keys
    end

    def known_options
      [:klass, :default, :negative, :alias, :parse_with, :extend]
    end

    # this helper raises an exception if the options passed to has_value
    # are wrong. Mostly written because I occasionally used :class instead
    # of :klass and, being a moron, wasted time trying to find the issue.
    def check_options_validity( class_name, attribute, options )
      invalid_options = options.keys - known_options

      raise ArgumentError, "has_value did not know how to respond to option(s) #{invalid_options.join(', ')}. Valid (optional) arguments are: #{known_options.join(', ')}" unless invalid_options.empty?    

      raise ArgumentError, "#{class_name} doesn't know how to format #{attribute} with :klass => #{options[:klass].inspect}" unless klass_options.any?{|klass| klass === options[:klass]}

      raise( ArgumentError, "#{class_name} can't promise to return a(n) #{options[:klass]} when using :parse_with" ) if options[:klass].is_a?( Symbol ) && options[:parse_with]
    end
  end
end

