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

    def deep_duplicate_of(value)
      Marshal.load(Marshal.dump(value))
    end

    def format( name, value, attributes, collection_item = false )
      klass = collection_item ? attributes[name][:item_klass] : attributes[name][:klass]

      case klass
      when NilClass

        value

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

        value && value.to_i

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
        else
          klass.send(attributes[name][:formatter] || :new, value)
        end

      end

    end
    
    def klass_options
      [NilClass, :integer, Class, :date, :decimal, :string, :boolean]
    end

    def known_options
     [:klass, :default, :negative, :alias, :formatter]
    end

    # this helper raises an exception if the options passed to has_value
    # are wrong. Mostly written because I occasionally used :class instead
    # of :klass and, being a moron, wasted time trying to find the issue.
    def check_options_validity( class_name, attribute, options )
      invalid_options = options.keys - known_options

      raise ArgumentError, "has_value did not know how to respond to option(s) #{invalid_options.join(', ')}. Valid (optional) arguments are: #{known_options.join(', ')}" unless invalid_options.empty?    

      raise ArgumentError, "#{class_name} doesn't know how to format #{attribute} with :klass => #{options[:klass].inspect}" unless klass_options.any?{|klass| klass === options[:klass]}
    end
  end
end

