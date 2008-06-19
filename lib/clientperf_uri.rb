class ClientperfUri < ActiveRecord::Base
  
  has_many :clientperf_results, :dependent => :delete_all do
    def last_hour
      end_time = (Time.now + 1.minute).change(:sec => 0)
      start_time = end_time - 1.hour
      results = average(:milliseconds, :conditions => ['created_at between ? and ?', start_time, end_time] ,
        :group => 'minute(created_at)')
      
      max = 0  
      padded_results = (start_time.min..start_time.min + 59).map do |i|
        minute = i % 60
        data = data_for(minute, results)
        max = data if data && data > max
        [minute, data]
      end
      [padded_results, max]
    end
    
    def last_day
      end_time = (Time.now + 1.hour).change(:min => 0)
      start_time = end_time - 1.day
      results = average(:milliseconds, :conditions => ['created_at between ? and ?', start_time, end_time], 
        :group => 'hour(created_at)')
      
      max = 0  
      padded_results = (start_time.hour..start_time.hour + 23).map do |i|
        hour = i % 24
        data = data_for(hour, results)
        max = data if data && data > max
        [hour, data]
      end
      [padded_results, max]  
    end
    
    def last_month
      end_time = (Time.now + 1.day).change(:hour => 0)
      start_time = end_time - 30.days
      results = average(:milliseconds, :conditions => ['created_at between ? and ?', start_time, end_time], 
        :group => 'day(created_at)')
        
      max = 0  
      padded_results = (start_time.day..start_time.day + 29).map do |i|
        day = i % Time.days_in_month(start_time.month)
        data = data_for(day, results)
        max = data if data && data > max
        [day, data]
      end
      [padded_results, max]
    end
    
    def data_for(point, results)
      data = results.detect {|p,d| point == p.to_i}
      data ? data[1].to_i : 0
    end
  end 
  
  def chart_url
    "http://chart.apis.google.com/chart?cht=ls&chs=300x50&chm=B&chd=s:"
  end
  
  def hour_chart
    "#{chart_url}#{chart_data(clientperf_results.last_hour)}"
  end
  
  def day_chart
    "#{chart_url}#{chart_data(clientperf_results.last_day)}"
  end
  
  def month_chart
    "#{chart_url}#{chart_data(clientperf_results.last_month)}"
  end
  
  private
  
  def chart_data(args)
    data, max = args
    max += 10
    encode = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

    data.map do |result|
      char = 62 * result[1] / max.to_f
      encode[char.round,1]
    end.join
  end
end