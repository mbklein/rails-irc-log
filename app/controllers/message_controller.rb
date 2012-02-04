class MessageController < ApplicationController

  helper LaterDude::CalendarHelper
  before_filter :set_param_variables
  
  def view_day
    @highlights = params[:highlight] || get_referer_search_terms
    @date = Time.local(@year,@month,@day)
    @messages = Message.find :all, :conditions => { :channel => "##{@channel}", :when => (@date..(@date+1.day-1.second))}
  end

  def view_month
    @linked_dates = Message.dates_with_messages @channel, @year, @month
  end

  def view_year
    @linked_dates = Message.dates_with_messages @channel, @year
  end
  
  def view_channel
    redirect_to year_path(@channel, Date.today.year)
  end
  
  def view_root
    @channels = Message.select(:channel).collect { |m| m.channel }.uniq.sort
  end

  def set_param_variables
    @channel = params[:channel]
    @year = params[:year].to_i
    @month = params[:month].to_i
    @day = params[:day].to_i
  end
  
  def get_referer_search_terms
    begin
      referer = URI.parse(request.referer)
      referer_params = CGI.parse(referer.query || '')
      terms = referer.host =~ /yahoo.com/ ? referer_params['p'] : (referer_params['q'] || referer_params['query'])
      terms.join(' ').scan(/(?:"")|(?:"(.*[^\\])")|(\w+)/).flatten.compact
    rescue URI::InvalidURIError
      []
    end
  end
  
end
