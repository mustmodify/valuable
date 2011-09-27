Introducing Valuable
====================

Valuable enables quick modeling... it's attr_accessor on steroids.  For all those times you wanted to use OO to model something but it seemed like too much of a pain, try Valuable. Its simple interface allows you to model without hassles, so you can get on with the logic specific to your application.

Frequent Uses:

**pre-refactor modeling** to model a class you want to abstract but know would be a pain... as in, "I would love to pull Appointment out of this WorkOrder class, but since that isn't going to happen soon, let me quickly create WorkOrder.appointments... I can then create Appointment\#to\_s, appointment.end_time, appointment.duration, etc. I can use that to facilitate emitting XML or doing something with views, rather than polluting WorkOrder with appointment-related logic." 

**as a presenter** as in, "I need to take in a few different models to generate this map... I need a class that models the integration, but I don't need to persist that to a database."

**creating models from non-standard data sources** to keep data from non-standard data sources in memory during an import or to render data from an API call.

Valuable provides DRY decoration like attr_accessor, but includes default values and other formatting (like, "2" => 2), and a constructor that accepts an attributes hash. It provides a class-level list of attributes, an instance-level attributes hash, and more.

Type Casting in Ruby? You must be crazy...
-------------------------------------------------------------
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

Default Values
--------------
Default values are used when no value is provided to the constructor. If the value nil is provided, nil will be used instead of the default.

When a default value and a klass are specified, the default value will NOT be cast to type klass -- you must do it.

If a value having a default is set to null after it is constructed, it will NOT be set to the default.

If there is no default value, the result will be nil, EVEN if type casting is provided. Thus, a field typically cast as an Integer can be nil. See calculation of average.

Examples
-------

_basic syntax_

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

_formatting aka light-weight type-casting_

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
      # - boolean ( NOTE: '0' casts to FALSE... I would be fascinated to know when this is not the correct behavior. )
      # - or any class ( formats as SomeClass.new( ) unless value.is_a?( SomeClass ) )


_collections_

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

_aliases_

      # This example requires active_support because of Hash.from_xml

      class Software < Valuable
        has_value :name, :alias => 'Title'
      end

      >> xml = '<software><Title>Windows XP</Title></software>'

      >> xp = Software.new(Hash.from_xml(xml)['software'])

      >> xp.name
      => "Windows XP"


_as a presenter in Rails_

      class CalenderPresenter < Valuable
        has_value :month, :klass => Integer, :default => Time.now.month
        has_value :year, :klass => Integer, :default => Time.now.year

        def start_date
          Date.civil( year, month, 1)
        end

        def end_date
          Date.civil( year, month, -1) #strange I know
        end

        def events
          Event.find(:all, :conditions => event_conditions)
        end

        def event_conditions
          ['starts_at between ? and ?', start_date, end_date]
        end
      end

this class might appear in a controller like this:

      class CalendarController < ApplicationController
        def show
          @presenter = CalendarPresenter.new(params[:calendar])
        end
      end

but it's easier to understand like this:

      >> @presenter = CalendarPresenter.new({}) # first pageload

      >> @presenter.start_date
      => Tue, 01 Dec 2009

      >> @presenter.end_date
      => Thu, 31 Dec 2009

      >> # User selects some other month and year; the next request looks like...

      >> @presenter = CalendarPresenter.new({:month => '2', :year => '2002'})

      >> @presenter.start_date
      => Fri, 01 Feb 2002

      >> @presenter.end_date
      => Thu, 28 Feb 2002

      ...

So, if you're reading this, you're probably thinking, "I could have done that!" Yes, it's true. I'll happily agree that it's a relatively simple tool if you'll agree that it lets you model a calendar with an intuitive syntax, prevents you from writing yet another obvious constructor, and allows you to keep your brain focused on your app.

_you can access the attributes via the attributes hash. Only default and specified attributes will have entries here._

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

_also, you can get a list of all the defined attributes from the class_

      >> Person.attributes
      => [:name, :is_developer, :ssn]


