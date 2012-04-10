Introducing Valuable
====================

Valuable enables quick modeling... it's attr_accessor on steroids.  Its simple interface allows you to build, change and discard models without hassles, so you can get on with the logic specific to your application.

Valuable provides DRY decoration like attr_accessor, but includes default values and other formatting (like, "2" => 2), and a constructor that accepts an attributes hash. It provides a class-level list of attributes, an instance-level attributes hash, and more.

Tested with [Rubinius](http://www.rubini.us "Rubinius"), 1.8.7, 1.9.1, 1.9.2, 1.9.3

Frequent Uses
-------------

**pre-refactor modeling** to model a class you want to abstract but know would be a pain... as in, "I would love to pull Appointment out of this WorkOrder class, but since that isn't going to happen soon, let me quickly create WorkOrder.appointments... I can then create Appointment\#to\_s, appointment.end_time, appointment.duration, etc. I can use that to facilitate emitting XML or doing something with views, rather than polluting WorkOrder with appointment-related logic." 

**as a presenter** as in, "I need to take in a few different models to generate this map... I need a class that models the integration, but I don't need to persist that to a database."

**creating models from non-standard data sources** to keep data from non-standard data sources in memory during an import or to render data from an API call.

Type Casting in Ruby? You must be crazy...
------------------------------------------
Yeah, I get that alot. I mean, about type casting. I'm not writing
C# over here. Rails does it, they just don't call it type casting,
so no one complains when they pass in "2" as a parameter and mysteriously
it ends up as an integer. In fact, I'm going to start using the euphamism
'Formatting' just so people will stop looking at me that way.

Say you're getting information for a directory from a web service via JSON:

      class Person < Valuable
        has_value :name
        has_value :age, :klass => :integer
        has_value :phone_number, :klass => PhoneNumber
               # see /examples/phone_number.rb

      'person' =>
        'name' => 'Mr. Freud',
        'age' => "344",
        'phone_number' => '8002195642',
        'specialization_code' => "2106"

you'll end up with this:

      >> p = Person.new(params[:person])

      >> p.age
      => 344

      >> p.phone_number
      => (337) 326-3121

      >> p.phone_number.class
      => PhoneNumber

"Yeah, I could have just done that myself."
"Right, but now you don't have to."

Basic Syntax
------------

      class Fruit < Valuable
        has_value :name
        has_collection :vitamins
      end

_constructor accepts an attributes hash_

      >> apple = Fruit.new(:name => 'Apple')

      >> apple.name
      => 'Apple'

      >> apple.vitamins
      => []

_default values_

Default values are used when no value is provided to the constructor. If the value nil is provided, nil will be used instead of the default. Default values are populated on instanciation.

When a default value and a klass are specified, the default value will NOT be cast to type klass -- you must do it.

If a value having a default is set to null after it is constructed, it will NOT be set to the default.

If there is no default value, the result will be nil, EVEN if type casting is provided. Thus, a field typically cast as an Integer can be nil. See calculation of average.

The :default option will accept a lambda and call it on instanciation.

      class Developer
        has_value :name
        has_value :nickname, :default => 'mort'
      end

      >> dev = Developer.new(:name => 'zk')

      >> dev.name
      => 'zk'

      >> dev.nickname
      => 'mort'

_setting a value to nil overrides the default._

      >> Developer.new(:name => 'KDD', :nickname => nil).nickname
      => nil

_aliases_

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
_aka light-weight type-casting_

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

      # Currently supports:
      # - integer
      # - decimal ( casts to BigDecimal... NOTE: nil remains nil, not 0 as in nil.to_i )
      # - string
      # - boolean ( NOTE: '0' casts to FALSE... This isn't intuitive, but I would be fascinated to know when this is not the correct behavior. )
      # - or any class ( formats as SomeClass.new( ) unless value.is_a?( SomeClass ) )

Collections
-----------

      class MailingList < Valuable
        has_collection :emails
      end

      >> m = MailingList.new

      >> m.emails
      => []

      >> m = MailingList.new(:emails => [ 'johnathon.e.wright@nasa.gov', 'other.people@wherever.com' ])

      => m.emails
      >> [ 'johnathon.e.wright@nasa.gov', 'other.people@wherever.com' ]

_formatting collections_

      class Player < Valuable
        has_value :first_name
        has_value :last_name
        has_value :salary
      end
        
      class Team < Valuable
        has_value :name
        has_value :long_name

        has_collection :players, :klass => Player
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

Advanced Defaults
-----------------

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

Note -- if you overwrite the constructor, you should call initialize_attributes. Otherwise, your default values won't be set up until the first time the attributes hash is called -- in theory, this could be well after initialization, and could cause unknowable gremlins. Trivial example:

      class Person
        has_value :created_at, :default => lambda { Time.now }

        def initialize(atts)
        end
      end

      >> p = Person.new 
      >> # wait 10 minutes
      >> p.created_at == Time.now  # attributes initialized on first use
      => true

Advanced Input Parsing
----------------------

Sometimes, .to_s isn't enough... the architypical example being Date.parse(value). In these cases, you can specify what class-level method should be used to process the input.

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

Parse via lambda:

      require 'active_support'

      class Movie < Valuable
        has_value :title, :parse_with => lambda{|x| x.titleize}
      end

      >> best_movie_ever = Movie.new(:title => 'the usual suspects')

      >> best_movie_ever.title
      => "The Usual Suspects"

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

Get a list of all the defined attributes from the class:

      >> Person.attributes
      => [:name, :is_developer, :ssn]

It's a relatively simple tool that lets you create models with a (hopefully) intuitive syntax, prevents you from writing yet another obvious constructor, and allows you to keep your brain focused on your app.

