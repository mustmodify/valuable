Introducing Valuable
====================

Valuable enables quick modeling... it's attr_accessor on steroids.  Its simple interface allows you to build, change and discard models without hassles, so you can get on with the logic specific to your application.

Valuable provides DRY decoration like attr_accessor, but includes default values and other formatting (like, "2" => 2), and a constructor that accepts an attributes hash. It provides a class-level list of attributes, an instance-level attributes hash, and more.

Tested with [Rubinius](http://www.rubini.us "Rubinius"), 1.8.7, 1.9.1, 1.9.2, 1.9.3

Version 0.9.x is considered stable.

Valuable was originally created to avoid the repetition of writing the constructor-accepts-a-hash method. It has evolved, but at its core are still the same concepts.

Contents
--------

- [Frequent Uses](#frequent-uses)
- [Methods](#methods) ( [Class-Level](#class-level-methods), [Instance-Level](#instance-level-methods) )
- [Installation](#installation)
- [Usage & Examples](#usage--examples)
    - [Constructor Accepts an Attributes Hash](#constructor-accepts-an-attributes-hash)
    - [Default Values](#default-values)
    - [Nil Values](#nil-values)
    - [Aliases](#aliases)
    - [Formatting Input](#formatting-input)
    - [Pre-Defined Formatters](#pre-defined-formatters)
    - [Extending Values](#extending-values)
    - [Collections](#collections)
    - [Formatting Collections](#formatting-collections)
    - [Extending Collections](#extending-collections)
    - [Registering Formatters](#registering-formatters)
    - [More about Attributes](#more-about-attributes)
    - [Advanced Input Parsing](#advanced-input-parsing)
    - [Advanced Defaults](#advanced-defaults)
    - [Advanced Collection Formatting](#advanced-collection-formatting)

Frequent Uses
=============

Valuable was created to help you quickly model things. Things I find myself modeling:

+ **data imported from JSON, XML, etc**
+ **the result of an API call**
+ **a subset of some data in an ORM class** say you have a class Person with street, city, state and zip. It might not make sense to store this in a separate table, but you can still create an Address model to hold address-related logic and state like geocode, post_office_box? and Address#==
+ **as a presenter that wraps a model** This way you keep view-specific methods out of views and models.
+ **as a presenter that aggregates several models** Generating a map might involve coordinating several different collections of data. Create a valuable class to handle that integration.
+ **to model search forms** - Use Valuable to model an advanced search form. Create an attribute for each drop-down, check-box, and text field, and constants to store options. Integrates easily with Rails via @search = CustomerSearch.new(params[:search]) and form_for(@search, :url => ...)
+ **to model reports** like search forms, reports can be stateful when they have critiera that can be selected via form.
+ **as a query builder** ie, "I need to create an (Arel or SQL) query based off of form input." (see previous two points)
+ **experiments / spikes**
+ **factories** factories need well-defined input, so valuable is a great fit.

Methods
=============

Class-Level Methods
-------------------

###has_value( field_name, options = {})

creates a getter and setter named field_name

options:
+ **default** - provide a default value

          class Task < Valuable
            has_value :status, :default => 'Active'
          end
          
          >> Task.new.status
          => 'Active'

+ **alias** - create setters and getters with the name of the attribute and _also_ with the alias. See [Aliases](#aliases) for more information.

+ **klass** - pre-format the input with one of the [predefined formatters](#pre-defined-formatters), as a class, or with your [custom formatter](#registering-formatters). See [Formatting Input](#formatting-input) for more information.

          class Person < Valuable
            has_value :age, :klass => :integer
            has_value :phone_number, :klass => PhoneNumber
          end
          
          >> Person.new(:age => '15').age.class
          => Fixnum

          >> jenny = Person.new(:phone_number => '2018675309')

          >> jenny.phone_number == PhoneNumber.new('2018675309')
          => true


+ **parse_with** - Sometimes you want to instantiate with a method other than new... one example being Date.parse

          class Person
            has_value :dob, :klass => Date, :parse_with => :parse
          end
          
          # this will call Date.parse('1976-07-26')
          Person.new(:dob => '1976-07-26')

###has_collection( field_name, options = {} )

like has_value, this creates a getter and setter. The default value is an array.

options:
+ **klass** - apply pre-defined or custom formatters to each element of the array.
+ **alias** - create additional getters and setters under this name.
+ **extend** - extend the collection with the provided module or modules.

        class Person
          has_collection :friends
        end

        >> Person.new.friends
        =>   []

###attributes

an array of attributes you have defined on a model.

      class Person < Valuable
        has_value :first_name
        has_value :last_name
      end

      >> Person.attributes
      => [:first_name, :last_name]

###defaults

A hash of the attributes with their default values. Attributes defined without default values do not appear in this list.

      class Pastry < Valuable
        has_value :primary_ingredient, :default => :sugar
        has_value :att_with_no_default
      end

      >> Pastry.defaults
      => {:primary_ingredient => :sugar}

###register_formatter(name, &block)

Allows you to provide custom code to pre-format attributes, if the included ones are not sufficient. For instance, you might wish to register an 'orientation' formatter that accepts either angles or 'N', 'S', 'E', 'W', and converts those to angles. See [registering formatters](#registering-formatters) for details and examples.
  
**Note:** as with other formatters, nil values will not be passed to the formatter. The attribute will simply be set to nil. See [nil values](#nil-values). If this is an issue, let me know.

###acts\_as\_permissive

Valuable classes typically raise an error if you instantiate them with attributes that have not been predefined. This method makes valuable ignore any unknown attributes.

Instance-Level Methods
----------------------

###attributes

    provides a hash of the attributes and their values.

      class Party < Valuable
        has_value :host
        has_value :theme
        has_value :time, :default => '6pm'
      end

      >> party = Party.new(:theme => 'Black and Whitle')

      >> party.attributes
      => {:theme => 'Black and White', :time => '6pm'}

      # note that the 'host' attribute was not set by default, at
      # instantiation, or via the setter method party.host=, so 
      # it does not appear in the attributes hash.

###update_attributes(atts={})

Accepts a hash of :attribute => :value and updates each associated attributes. Will raise an exception if any of the keys isn't already set up in the class, unless you call acts_as_permissive.
  
      class Tomatoe
        has_value :color
      end
  
      >> t = Tomatoe.new(:color => 'green')
      >> t.color
      => 'green'
      >> t.update_attributes(:color => 'red')
      >> t.color
      => 'red'

###write_attribute(att_name, value)

this method is called by all the setters and, obviously, update_attributes.  Using a formatter (if specified), it updates the attributes hash.

      class Chicken
        has_value :gender
      end
    
      >> c = Chicken.new
    
      >> c.gender
      => nil
    
      >> c.write_attribute(:gender, 'F')
    
      >> c.gender
      => 'F'

Installation
============

if using bundler, add this to your gemfile:

      gem 'valuable'

and the examples below should work.

Usage & Examples
================

      class Person < Valuable
        has_value :name
        has_value :age, :klass => :integer
        has_value :phone_number, :klass => PhoneNumber
               # see /examples/phone_number.rb
      end
      
      params = 
      {
        'person' =>
        {
          'name' => 'Mr. Freud',
          'age' => "344",
          'phone_number' => '8002195642',
          'specialization_code' => "2106"
        }
      }

      >> p = Person.new(params[:person])

      >> p.age
      => 344

      >> p.phone_number
      => (337) 326-3121

      >> p.phone_number.class
      => PhoneNumber

"Yeah, I could have just done that myself."

"Right, but now you don't have to."


Constructor Accepts an Attributes Hash
--------------------------------------

      >> apple = Fruit.new(:name => 'Apple')

      >> apple.name
      => 'Apple'

      >> apple.vitamins
      => []

Default Values
--------------

Default values are... um... you know.

      class Developer
        has_value :name
        has_value :nickname, :default => 'mort'
      end

      >> dev = Developer.new(:name => 'zk')

      >> dev.name
      => 'zk'

      >> dev.nickname
      => 'mort'

If there is no default value, the result will be nil, EVEN if type casting is provided. Thus, a field typically cast as an Integer can be nil. See calculation of average example.

See also:
+ [nil values](#nil-values)
+ [Advanced Defaults](#advanced-defaults) 

**Note:** When a default value and a klass are specified, the default value will NOT be cast to type klass -- you must do it. Example:

      class Person

        # WRONG!
        has_value :dob, :klass => Date, :default => '2012-07-26'

        # Correct
        has_value :dob, :klass => Date, :default => Date.parse('2012-07-26')

      end


Nil Values
----------

Setting an attribute to nil always results in it being nil. [Default values](#default-values), [pre-defined formatters](#pre-defined-formatters), and [custom formatters](#registering-formatters) have no effect.

      class Account
        has_value :logins, :klass => :integer, :default => 0
      end

      >> Account.new(:logins => nil).loginx
      => nil 

      # note this is not the same as
      >> nil.to_i
      => 0

Aliases
-------

Set additional getters and setters. Useful when outside data sources have odd field names.

      # This example requires active_support because of Hash.from_xml

      class Software < Valuable
        has_value :name, :alias => 'Title'
      end

      >> xml = '<software><Title>Windows XP</Title></software>'

      >> xp = Software.new(Hash.from_xml(xml)['software'])

      >> xp.name
      => "Windows XP"

Formatting Input
----------------

The purpose of Valuable's attribute formatting is to ensure that a model's input is "corrected" and ready for use as soon as the class is instantiated. Valuable provides several formatters by default -- :integer, :boolean, and :date are a few of them. You can optionally write your own formatters -- see [Registering Formatters](#registering-formatters)

      class BaseballPlayer < Valuable

        has_value :at_bats, :klass => :integer
        has_value :hits, :klass => :integer

        def average
          hits/at_bats.to_f if hits && at_bats
        end
      end

      >> joe = BaseballPlayer.new(:hits => '5', :at_bats => '20', :on_drugs => '0' == '1')

      >> joe.at_bats
      => 20

      >> joe.average
      => 0.25

Pre-Defined Formatters
----------------------

see also [Registering Formatters](#registering-formatters)
- integer ( see [nil values](#nil-values) )
- decimal ( casts to BigDecimal. see [nil values](#nil-values) )
- date    ( see [nil values](#nil-values) )
- string  
- boolean ( NOTE: '0' casts to FALSE... I'm not sure whether this is intuitive, but I would be fascinated to know 
         when this is not the correct behavior. )
- or any class ( formats as SomeClass.new( ) unless value.is_a?( SomeClass ) )

Extending Values
----------------

As with has_value, you can do something like:

      module PirateTranslator
        def to_pirate
          "#{self} AAARRRRRGgghhhh!"
        end
      end

      class Envelope < Valuable
        has_value :message, :extend => PirateTranslator
      end

      >> Envelope.new(:message => 'contrived').message.to_pirate
      => "contrived AAARRRRRGgghhhh!"

Collections
-----------

      has_collection :codez

is similar to:

      has_value :codez, :default => []

except 
  * it reads better
  * that the formatter is applied to the collection's members, not (obviously) the collection. See [Formatting Collections](#formatting-collections) for more details.

      class MailingList < Valuable
        has_collection :emails
        has_collection :messages, :klass => BulkMessage
      end

      >> m = MailingList.new

      >> m.emails
      => []

      >> m = MailingList.new(:emails => [ 'johnathon.e.wright@nasa.gov', 'other.people@wherever.com' ])

      => m.emails
      >> [ 'johnathon.e.wright@nasa.gov', 'other.people@wherever.com' ]

Formatting Collections
----------------------

If a klass is specified, members of the collection will be formatted appropriately:

      >> m.messages << "Houston, we have a problem"
      
      >> m.messages.first.class
      => BulkMessage

see [Advanced Collection Formatting](#advanced-collection-formatting) for more complex examples.

Extending Collections
---------------------

As with has_value, you can do something like:

      module PirateTranslator
        def to_pirate
          "#{self} AAARRRRRGgghhhh!"
        end
      end

      class Envelope < Valuable
        has_value :message, :extend => PirateTranslator
      end

      >> Envelope.new(:message => 'contrived').message.to_pirate
      => "contrived AAARRRRRGgghhhh!"

Registering Formatters
----------------------

If the default formatters don't suit your needs, Valuable allows you to write your own formatting code via register_formatter. You can even override the predefined formatters simply by registering a formatter with the same name.

      # In honor of NASA's Curiosity rover, let's say you were modeling
      # a rover. Here's the valuable class:

      class Rover < Valuable
        has_value :orientation
      end

      Sometimes orientation comes in as 'N', 'E', 'S' or 'W', sometimes it comes in as an orientation in degrees as a string ("92"), and sometimes it comes in as an integer. Let's create a formatter that makes sure everything is formatted in degrees. Notice that we're registering this formatter on Valuable, not on Rover. It will be available to every Valuable model.

     Valuable.register_formatter(:orientation) do |value|
        case value
        when Numeric
          value
        when /^\d{1,3}$/
          value.to_i
        when 'N', 'North'
          0
        when 'E', 'East'
          90
        when 'S', 'South'
          180
        when 'W', 'West'
          270
        else
          nil
        end
      end
 
      and then we update rover to use the new formatter:

      class Rover < Valuable
        has_value :orientation, :klass => :orientation
      end

      >> Rover.new(:orientation => 90).orientation
      => 90

      >> Rover.new(:orientation => '282').orientation
      >> 282

      >> Rover.new(:orientation => 'S').orientation
      => 180

More about Attributes
---------------------

Access the attributes via the attributes hash. Only default and specified attributes will have entries here.

      class Person < Valuable
        has_value :name
        has_value :is_developer, :default => false
        has_value :ssn
      end

      >> elvis = Person.new(:name => 'The King')

      >> elvis.attributes
      => {:name=>"The King", :is_developer=>false}

      >> elvis.attributes[:name]
      => "The King"

      >> elvis.ssn
      => nil

      >> elvis.attributes.has_key?(:ssn)
      => false

      >> elvis.ssn = '409-52-2002'  # allegedly

      >> elvis.attributes[:ssn]
      => "409-52-2002"

You _can_ write directly to the attributes hash. As far as I know, Valuable will not care. However, formatters will not be applied.

Get a list of all the defined attributes from the class:

      >> Person.attributes
      => [:name, :is_developer, :ssn]

Advanced Input Parsing
----------------------

When you specify a klass, Valuable will pass any input (that isn't already that klass) to the constructor. If you want to use a class-level method other than the constructor, pass the method name to parse\_with. Perhaps it should have been called :construct\_with. :)

Default behavior:

      class Customer
        has_value :payment_method, :klass => PaymentMethod
      end
      
      # this will call PaymentMethod.new('1232123')
      Customer.new(:payment_method => '1232123')

using parse_with:

      require 'date'

      class Person < Valuable
        has_value :date_of_birth, :alias => :dob, :klass => Date, :parse_with => :parse

        def age_in_days
          Date.today - dob
        end
      end

      >> sammy = Person.new(:dob => '2012-02-17')
      >> sammy.age_in_days
      => Rational(8, 1)

example using a lookup method:

      class Person < ActiveRecord::Base
        def find_by_full_name( full_name )
          #some finder code
        end
      end
      
      class Photograph < Valuable
        has_value :photographer, :klass => Person
      end


use it to load associated data from an exising set...

      class Planet < Valuable
        has_value :name
        has_value :spaceport

        def Planet.list
          @list ||= []
        end

        def Planet.find_by_name( needle )
          list.find{|i| i.name == needle }
        end
      end

      class Spaceship < Valuable
        has_value :name
        has_value :home, :klass => Planet, :parse_with => :find_by_name
      end

      Planet.list << Planet.new(:name => 'Earth', :spaceport => 'KSC')
      Planet.list << Planet.new(:name => 'Mars', :spaceport => 'Olympus Mons')

      >> vger = Spaceship.new( :name => "V'ger", :home => 'Earth')
      >> vger.home.spaceport
      => 'KSC'

You can also provide a lambda. This is similar to specifying a custom formatter, except that it only applies to this attribute and can not be re-used.

      require 'active_support'

      class Movie < Valuable
        has_value :title, :parse_with => lambda{|x| x.titleize}
      end

      >> best_movie_ever = Movie.new(:title => 'the usual suspects')

      >> best_movie_ever.title
      => "The Usual Suspects"

Advanced Defaults
-----------------

The :default option will accept a lambda and call it on instantiation.

      class Borg < Valuable
        cattr_accessor :count
        has_value :position, :default => lambda { Borg.count += 1 }
      
        def designation
          "#{self.position} of #{Borg.count}"
        end
      end

      >> Borg.count = 6
      >> seven = Borg.new
      >> Borg.count = 9
      >> seven.designation
      => '7 of 9'

**Caution** -- if you overwrite the constructor, you should call initialize_attributes. Otherwise, your default values won't be set up until the first time the attributes hash is called -- in theory, this could be well after initialization, and could cause unknowable gremlins. Trivial example:

      class Person
        has_value :created_at, :default => lambda { Time.now }

        def initialize(atts)
        end
      end

      >> p = Person.new 
      >> # wait 10 minutes
      >> p.created_at == Time.now  # attributes initialized on first use
      => true

Advanced Collection Formatting
------------------------------

see [Collections](#collections) and [Formatting Collections](#formatting-collections) for basic examples. A more complex example involves nested Valuable models:
        
      class Team < Valuable
        has_value :name
        has_value :long_name

        has_collection :players, :klass => Player
      end
 
      class Player < Valuable
        has_value :first_name
        has_value :last_name
        has_value :salary
      end

      t = Team.new(:name => 'Toronto', :long_name => 'The Toronto Blue Jays', 
               'players' => [
                    {'first_name' => 'Chad', 'last_name' => 'Beck', :salary => 'n/a'},
                    {'first_name' => 'Shawn', 'last_name' => 'Camp', :salary => '2250000'},
                    {'first_name' => 'Brett', 'last_name' => 'Cecil', :salary => '443100'},
                    Player.new(:first_name => 'Travis', :last_name => 'Snider', :salary => '435800')
                  ])

      >> t.players.first
      => #<Player:0x7fa51e4a1da0 @attributes={:salary=>"n/a", :first_name=>"Chad", :last_name=>"Beck"}>

      >> t.players.last
      => #<Player:0x7fa51ea6a9f8 @attributes={:salary=>"435800", :first_name=>"Travis", :last_name=>"Snider"}>

parse_with parses each item in a collection...

      class Roster < Valuable
        has_collection :players, :klass => Player, :parse_with => :find_by_name
      end


