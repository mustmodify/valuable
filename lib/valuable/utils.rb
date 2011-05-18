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

    def cast( name, value, attributes, collection_item = false )
      klass = collection_item ? attributes[name][:item_klass] : attributes[name][:klass]

      case klass
      when NilClass

        value

      when :collection
        if( value.kind_of?(Array) )
          out = value.map do |item|
            Valuable::Utils.cast( name, item, attributes, true )
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
          klass.new(value)
        end

      end

    end
  end
end

