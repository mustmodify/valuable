Introducing Valuable
====================

Valuable enables quick modeling... it's attr_accessor on steroids.  It intends to use a simple and intuitive interface, allowing you easily create models without hassles, so you can get on with the logic specific to your application. I find myself using it in sort of a presenter capacity, when I have to pull data from non-standard data sources, and to handle temporary data during imports.

Valuable provides DRY decoration like attr_accessor, but includes default values, light weight type casting and a constructor that accepts an attributes hash. It provides a class-level list of attributes, an instance-level attributes hash, and more.

Examples
-------

_basic syntax_

      class Fruit
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

_light weight type casting_

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

_aliases_

      # This example requires active_support because of Hash.from_xml

      class Software < Valuable
        has_value :name, :alias => 'Title'
      end

      >> xml = '<software><Title>Windows XP</Title></software>'

      >> xp = Software.new(:Title => Hash.from_xml(xml)['software'])

      >> xp.name
      => "Windows XP"


_I find myself using classes to format things... ( PhoneNumber is provided in `/examples` )_

      class School < Valuable
        has_value :name
        has_value :phone, :klass => PhoneNumber
      end

      >> School.new(:name => 'Vanderbilt', :phone => '3332223333').phone
      => '(333) 222-3333'

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

_this class might appear in a controller like this:_

      class CalendarController < ApplicationController
        def show
          @presenter = CalendarPresenter.new(params[:calendar])
        end
      end

_but it's easier to understand like this:_

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

Default Values
--------------
Default values are used when no value is provided to the constructor. If the value nil is provided, nil will be used instead of the default. 

When a default value and a klass are specified, the default value will NOT be cast to type klass -- you must do it.

If a value having a default is set to null after it is constructed, it will NOT be set to the default.

If there is no default value, the result will be nil, EVEN if type casting is provided. Thus, a field typically cast as an Integer can be nil. See calculation of average.

KLASS-ification
---------------
`:integer`, `:string` and `:boolean` use `to_i`, `to_s` and `!!` respectively. All other klasses use `klass.new(value)` unless the value `is_a?(klass)`, in which case it is unmolested. Nils are never klassified. In the example above, hits, which is an integer, is `nil` if not set, rather than `nil.to_i = 0`.
