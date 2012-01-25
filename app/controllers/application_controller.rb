class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_timezone
  
  def set_timezone
    if params[:tz]
      cookies[:tz] = { :value => params[:tz], :path => '/', :expires => 10.years.from_now }
      redirect_to request.path
    end
    Time.zone = cookies[:tz] unless cookies[:tz].nil?
  end
end
