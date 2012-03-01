class Message < ActiveRecord::Base

  def self.messages_for? channel, date
    self.find(:first, :conditions => { :channel => "##{channel}", :when => (date..(date+1.day)) }) ? true : false
  end

  def self.dates_with_messages channel, year=nil, month=nil
    if year.nil?
      year = Date.current.year
    end
    start_time = month.nil? ? Time.local(year,1,1) : Time.local(year,month,1)
    end_time = start_time + (month.nil? ? 1.year : 1.month) - 1.second
    dates = self.find :all, :conditions => { :channel => channel, :when => start_time.utc..end_time.utc }
    dates.collect { |d| d.when.localtime.to_date }.sort.uniq
  end
  
end
