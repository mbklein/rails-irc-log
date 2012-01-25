module MessageHelper
  
  def years_with_messages channel, start
    Message.find(:all, :select => '"when"', :conditions => { :where => "##{channel}" }).collect { |m| m.when.year }.uniq.sort.reverse
  end

  def month_display_opts
    {
      :previous_month => ['&laquo;', lambda { |date| month_path(params[:channel], date.year, date.month) }],
      :current_month => lambda { |date| "#{I18n.localize(date, :format => '%B')} #{link_to(date.year, year_path(params[:channel], date.year))}" },
      :next_month => ['&raquo;', lambda { |date| month_path(params[:channel], date.year, date.month) }]
    }
  end
  
  def year_display_opts
    {
      :current_month => ['%B', lambda { |date| month_path(params[:channel], date.year, date.month) }]
    }
  end
  
  def path_for_date channel, date
    day_path(channel, date.year, date.month, date.day)
  end
  
end
