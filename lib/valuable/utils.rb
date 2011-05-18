module Valuable::Utils
  class << self

    def deep_duplicate_of(value)
      Marshal.load(Marshal.dump(value))
    end

    def cast( name, value, attributes )
      klass = attributes[name][:klass]

      case klass
      when NilClass
              
        value

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

