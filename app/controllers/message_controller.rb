class MessageController < ApplicationController

  helper LaterDude::CalendarHelper
  before_filter :set_param_variables
  
  def view_day
    @highlights = params[:highlight] || get_referer_search_terms
    @date = Time.local(@year,@month,@day).utc
    @messages = Message.find :all, :conditions => { :channel => "##{@channel}", :when => (@date..(@date+1.day-1.second))}
  end

  def view_month
    with_time_zone 'UTC' do
      @linked_dates = Message.dates_with_messages "##{@channel}", @year, @month
    end
  end

  def view_year
    with_time_zone 'UTC' do
      @linked_dates = Message.dates_with_messages "##{@channel}", @year
    end
  end
  
  def view_channel
    redirect_to year_path(@channel, Date.today.year)
  end
  
  def view_root
    @channels = Message.select('DISTINCT channel').collect { |m| m.channel }.sort
  end

  def generate_sitemap
    with_time_zone 'UTC' do
      @channels = Message.select('DISTINCT channel').collect { |m| m.channel }.sort
      root = URI.parse(request.url).merge('/')
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.urlset(:xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9') do
          @channels.each { |channel|
            Message.dates_with_messages(channel).each { |date|
              xml.url do
                xml.loc root.merge(day_path :channel => channel.sub(/^#/,''), :year => date.year, :month => date.month, :day => date.day).to_s
                xml.lastmod date.strftime '%Y-%m-%d'
              end
            }
          }
        end
      end
      render :xml => builder.doc.to_xml
    end
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
