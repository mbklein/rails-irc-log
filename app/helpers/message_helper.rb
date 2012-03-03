module MessageHelper
  
  def display_month date
    I18n.localize(date, :format => '%B')
  end
  
  def display_day_month date
    I18n.localize(date, :format => '%b %d').gsub(/\b0/,'')
  end
  
  def format_msg text
    if text =~ /^\001ACTION (.+)\001$/
      content_tag('i', auto_link($1.strip))
    elsif (text =~ /^(joined|left) #/)
      content_tag('i', text) if is_true?(params[:joins])
    else
      result = text.split(/\n\n/).collect { |p| content_tag('p', auto_link(p)) }.join('')
      @highlights.each do |hl|
        result.gsub!(/\b#{hl}\b/i) { |m| content_tag('span', m, :class => 'highlight') }
      end
      result.html_safe
    end
  end
  
  def month_display_opts
    {
      :previous_month => ['&laquo;', lambda { |date| 
        Message.dates_with_messages(@channel, date.year, date.month).empty? ? nil : month_path(@channel, date.year, date.month) 
      }],
      :current_month => lambda { |date| "#{display_month(date)} #{link_to(date.year, year_path(@channel, date.year))}" },
      :next_month => ['&raquo;', lambda { |date| 
        Message.dates_with_messages(@channel, date.year, date.month).empty? ? nil : month_path(@channel, date.year, date.month) 
      }]
    }
  end
  
  def year_display_opts
    {
#      :current_month => ['%B', lambda { |date| month_path(@channel, date.year, date.month) }]
    }
  end
  
  def path_for_date channel, date
    day_path(channel, date.year, date.month, date.day)
  end
  
  def next_day_with_messages channel, date
    msg = Message.after_date(channel, date)
    Rails.logger.info(msg.inspect)
    unless msg.nil?
      date = msg.when
      link_to("#{display_day_month(date)} &raquo;".html_safe, path_for_date(channel,date))
    end
  end
  
  def previous_day_with_messages channel, date
    msg = Message.before_date(channel, date)
    Rails.logger.info(msg.inspect)
    unless msg.nil?
      date = msg.when
      link_to("&laquo; #{display_day_month(date)}".html_safe, path_for_date(channel,date))
    end
  end
  
  def next_year_with_messages channel, year
    msg = Message.after_date(channel, Time.zone.local(year,12,31))
    Rails.logger.info(msg.inspect)
    unless msg.nil?
      date = msg.when
      link_to "#{date.year} &raquo;".html_safe, year_path(channel, date.year)
    end
  end
  
  def previous_year_with_messages channel, year
    msg = Message.before_date(channel, Time.zone.local(year,1,1))
    Rails.logger.info(msg.inspect)
    unless msg.nil?
      date = msg.when
      link_to "&laquo; #{date.year}".html_safe, year_path(channel, date.year)
    end
  end
  
  def time_zone_list
    current = Time.zone.utc_offset
      [
        ["Kwajalein", -43200, "(GMT -12:00) Eniwetok, Kwajalein"], 
        ["Pacific/Samoa", -39600, "(GMT -11:00) Midway Island, Samoa"], 
        ["US/Hawaii", -36000, "(GMT -10:00) Hawaii"], 
        ["US/Alaska", -32400, "(GMT -9:00) Alaska"], 
        ["US/Pacific", -28800, "(GMT -8:00) Pacific Time (US & Canada)"], 
        ["US/Mountain", -25200, "(GMT -7:00) Mountain Time (US & Canada)"], 
        ["US/Central", -21600, "(GMT -6:00) Central Time (US & Canada), Mexico City"], 
        ["US/Eastern", -18000, "(GMT -5:00) Eastern Time (US & Canada), Bogota, Lima"], 
        ["Canada/Atlantic", -14400, "(GMT -4:00) Atlantic Time (Canada), Caracas, La Paz"], 
        ["Canada/Newfoundland", -12600, "(GMT -3:30) Newfoundland"], 
        ["Brazil/East", -10800, "(GMT -3:00) Brazil, Buenos Aires, Georgetown"], 
        ["Atlantic/Cape_Verde", -7200, "(GMT -2:00) Cape Verde"], 
        ["Atlantic/Azores", -3600, "(GMT -1:00 hour) Azores"], 
        ["GMT", 0, "(GMT) Western Europe Time, London, Lisbon, Casablanca"], 
        ["Europe/Paris", 3600, "(GMT +1:00 hour) Brussels, Copenhagen, Madrid, Paris"], 
        ["Africa/Johannesburg", 7200, "(GMT +2:00) Kaliningrad, South Africa"], 
        ["Europe/Moscow", 10800, "(GMT +3:00) Baghdad, Riyadh, Moscow, St. Petersburg"], 
        ["Asia/Tehran", 12600, "(GMT +3:30) Tehran"], 
        ["Asia/Tbilisi", 14400, "(GMT +4:00) Abu Dhabi, Muscat, Baku, Tbilisi"], 
        ["Asia/Kabul", 16200, "(GMT +4:30) Kabul"], 
        ["Asia/Karachi", 18000, "(GMT +5:00) Ekaterinburg, Islamabad, Karachi, Tashkent"], 
        ["Asia/Calcutta", 19800, "(GMT +5:30) Bombay, Calcutta, Madras, New Delhi"], 
        ["Asia/Kathmandu", 19800, "(GMT +5:45) Kathmandu"], 
        ["Asia/Dhaka", 21600, "(GMT +6:00) Almaty, Dhaka, Colombo"], 
        ["Asia/Bangkok", 25200, "(GMT +7:00) Bangkok, Hanoi, Jakarta"], 
        ["Asia/Singapore", 28800, "(GMT +8:00) Beijing, Perth, Singapore, Hong Kong"], 
        ["Asia/Tokyo", 32400, "(GMT +9:00) Tokyo, Seoul, Osaka, Sapporo, Yakutsk"], 
        ["Australia/Adelaide", 34200, "(GMT +9:30) Adelaide, Darwin"], 
        ["Pacific/Guam", 36000, "(GMT +10:00) Eastern Australia, Guam, Vladivostok"], 
        ["Asia/Magadan", 39600, "(GMT +11:00) Magadan, Solomon Islands, New Caledonia"], 
        ["Pacific/Auckland", 43200, "(GMT +12:00) Auckland, Wellington, Fiji, Kamchatka"]
      ].collect { |tzid,offset,name| 
      o = { :value => tzid }
      o[:selected] = 'yes' if offset == current
      content_tag('option', name, o)
    }.join('').html_safe
  end
  
end
