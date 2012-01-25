class Message < ActiveRecord::Base

  def self.messages_for? channel, date
    self.find(:first, :conditions => { :where => "##{channel}", :when => (date..(date+1.day)) }) ? true : false
  end

end
