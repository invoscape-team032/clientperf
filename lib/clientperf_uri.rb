class ClientperfUri < ActiveRecord::Base
  include ClientperfDataBuilder
  has_many :clientperf_results, :dependent => :delete_all
  
  def last_24_hours
    start_time = (Time.now + 1.hour - 1.day).change(:min => 0)
    results = clientperf_results.average(:milliseconds, :conditions => ['created_at > ?', start_time], 
      :group => "date_format(created_at,'%Y-%m-%d %H')")
      
    build_data_for_chart(results, start_time, 23, :hours) 
  end
  
  def last_30_days
    start_time = (Time.now + 1.day - 30.days).change(:hour => 0)
    results = clientperf_results.average(:milliseconds, :conditions => ['created_at > ?', start_time], 
      :group => "date_format(created_at,'%Y-%m-%d')")
      
    build_data_for_chart(results, start_time, 29, :days)
  end
end