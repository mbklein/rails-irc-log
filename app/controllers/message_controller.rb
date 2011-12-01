class MessageController < ApplicationController

  helper LaterDude::CalendarHelper
  
  def view_day
    @date = Time.local(params[:year],params[:month],params[:day])
    @messages = Message.find :all, :conditions => { :where => "##{params[:channel]}", :when => (@date..(@date+1.day-1.second))}
  end

  def view_month
    
  end
  
end
