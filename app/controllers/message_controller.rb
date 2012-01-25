class MessageController < ApplicationController

  helper LaterDude::CalendarHelper
  
  def view_day
    @date = Time.local(params[:year],params[:month],params[:day])
    @messages = Message.find :all, :conditions => { :where => "##{params[:channel]}", :when => (@date..(@date+1.day-1.second))}
  end

  def view_month
  end

  def view_year
  end
  
  def view_channel
    redirect_to year_path(params[:channel], Date.today.year)
  end
  
  def view_root
    @channels = Message.select('"where"').collect { |m| m.where }.uniq.sort
  end
  
end
