class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_timezone
  
  def with_time_zone(tz)
    result = nil
    old_tz = Time.zone
    Time.zone = tz
    begin
      result = yield
    ensure
      Time.zone = old_tz
    end
    return result
  end
  
  def set_timezone
    if params[:tz]
      cookies[:tz] = { :value => params[:tz], :path => '/', :expires => 10.years.from_now }
      redirect_to request.path
    end
    Time.zone = cookies[:tz].nil? ? 'America/New_York' : cookies[:tz]
  end
end
