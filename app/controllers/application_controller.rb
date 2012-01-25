class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_timezone
  
  def set_timezone
    if params[:tz]
      cookies[:tz] = params[:tz]
      redirect_to request.path
    end
    Time.zone = cookies[:tz] unless cookies[:tz].nil?
  end
end
