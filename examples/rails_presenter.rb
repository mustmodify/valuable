#  This class might appear in a controller like this:
#  
#  class CalendarController < ApplicationController
#    def show
#      @presenter = CalendarPresenter.new(params[:calendar])
#    end
#  end
#
#  but in documentation, makes more sense this way :)  
#  
#  >> @presenter = CalendarPresenter.new # first pageload
#  
#  >> @presenter.start_date
#  => Tue, 01 Dec 2009
#  
#  >> @presenter.end_date
#  => Thu, 31 Dec 2009
#  
#  >> # User selects some other month and year; the next request looks like...
#  
#  >> @presenter = CalendarPresenter.new({:month => '2', :year => '2002'})
#  
#  >> @presenter.start_date
#  => Fri, 01 Feb 2002
#  
#  >> @presenter.end_date
#  => Thu, 28 Feb 2002
#  
#  ...
#  
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

