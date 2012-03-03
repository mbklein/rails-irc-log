class MessageController < ApplicationController

  helper LaterDude::CalendarHelper
  before_filter :set_param_variables
  
  def view_day
    @highlights = params[:highlight] || get_referer_search_terms
    @date = Time.zone.local(@year,@month,@day)
    @messages = Message.messages_for @channel, @date
  end

  def view_month
    @linked_dates = Message.dates_with_messages "##{@channel}", @year, @month
  end

  def view_year
    @linked_dates = Message.dates_with_messages "##{@channel}", @year
  end
  
  def view_channel
    redirect_to year_path(@channel, Date.today.year)
  end
  
  def view_root
    @channels = Message.select('DISTINCT channel').collect { |m| m.channel }.sort
  end

  def generate_sitemap
    @channels = Message.select('DISTINCT channel').collect { |m| m.channel }.sort
    root = URI.parse(request.url).merge('/')
    routes = @channels.collect { |channel|
      dates = Message.dates_with_messages(channel)
      locs = dates.collect { |date|
        { 
          :lastmod => Date.today.strftime('%Y-%m-%d'), 
#          :lastmod => date.strftime('%Y-%m-%d'), 
          :loc => root.merge(day_path :channel => channel.sub(/^#/,''), :year => date.year, :month => date.month, :day => date.day).to_s 
        }
      }
#      locs += dates.group_by { |d| d.year }.collect { |y,d| d.max }.collect { |date|
#        {
#          :lastmod => date.strftime('%Y-%m-%d'), 
#          :loc => root.merge(year_path :channel => channel.sub(/^#/,''), :year => date.year).to_s 
#        }
#      }
    }.flatten

    respond_to do |format|
      format.json { render :json => routes.to_json }
      format.text { render :text => routes.collect { |route| route[:loc] }.join("\n") }
      format.xml  {
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.urlset(:xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9') do
            routes.each { |route|
              xml.url do
                xml.loc route[:loc]
                xml.lastmod route[:lastmod]
              end
            }
          end
        end
        render :xml => builder.doc.to_xml
      }
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
