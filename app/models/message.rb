class Message < ActiveRecord::Base

  def self.messages_for? channel, date
    self.find(:first, :conditions => { :channel => "##{channel}", :when => (date..(date+1.day)) }) ? true : false
  end

  def self.dates_with_messages channel, year=nil, month=nil
    if year.nil?
      year = Date.current.year
    end
    start_date = month.nil? ? Date.new(year,1,1) : Date.new(year,month,1)
    end_date = start_date + (month.nil? ? 1.year : 1.month)
    dates = self.find :all, :select => %{DISTINCT SUBSTR(`when`,1,10) AS `when`}, 
      :conditions => { :channel => channel, :when => start_date..end_date }
    dates.collect { |d| d.when.to_date }.sort
  end
  
end
