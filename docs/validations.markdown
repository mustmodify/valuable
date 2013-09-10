Validations via ActiveModel::Validations
========================================

Valuable doesn't support validations because other people are already doing that well. Here are examples of using the ActiveModel gem for validations:

      class Entity < Valuable
        include ActiveModel::Validations
      
        has_value :name
        has_value :avatar
      
        validates_presence_of :name
        validates_presence_of :avatar
      end
      
      >> entity = Entity.new(:name => 'Crystaline Entity')
      
      >> entity.valid?
      => false
      
      >> entity.errors.full_messages
      => ["Avatar can't be blank"]

Example using validators
------------------------

less talk; more code:

      class BorgValidator < ActiveModel::Validator
        def validate( entity )
          if( entity.name.to_s == "" )
            entity.errors[:name] << 'is blank and will be assimilated.'
          elsif( entity.name !~ /(\d+) of (\d+)/ )
            entity.errors[:name] << 'does not conform and will be assimilated.'
          end
        end
      end
      
      class Entity < Valuable
        include ActiveModel::Validations
        validates_with BorgValidator
      
        has_value :name
      
        validates_presence_of :name
      end
      
      >> hugh = Entity.new(:name => 'Hugh')
      
      >> hugh.valid?
      => false
      
      >> hugh.errors.full_messages
      => ["Name does not conform and will be assimilated"]
      
      >> high = Entity.new(:name => '3 of 7')
      
      >> hugh.valid?
      => true

