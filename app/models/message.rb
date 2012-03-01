class Message < ActiveRecord::Base

  def self.messages_for? channel, date
    self.find(:first, :conditions => { :channel => "##{channel}", :when => (date..(date+1.day-1.second)) }) ? true : false
  end

  def self.messages_for channel, date
    self.find(:all, :conditions => { :channel => "##{channel}", :when => (date..(date+1.day-1.second)) })
  end
  
  def self.dates_with_messages channel, year=nil, month=nil
    if year.nil?
      year = Date.current.year
    end
    start_time = month.nil? ? Time.zone.local(year,1,1) : Time.zone.local(year,month,1)
    end_time = start_time + (month.nil? ? 1.year : 1.month) - 1.second
    dates = self.find :all, :conditions => { :channel => channel, :when => start_time..end_time }
    dates.collect { |d| d.when.to_date }.sort.uniq
  end
  
end
