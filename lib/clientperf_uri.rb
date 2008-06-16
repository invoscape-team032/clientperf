class ClientperfUri < ActiveRecord::Base
  has_many :clientperf_results, :dependent => :delete_all

  def result_average
    @result_average ||= clientperf_results.inject(0) {|sum, result| sum += result.milliseconds; next sum} / clientperf_results.size
  end
  
  def chart_url
    "http://chart.apis.google.com/chart?cht=ls&chs=300x200&chd=s:#{chart_data}"
  end
  
  private 
  
  def chart_data
    encode = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    max_value = clientperf_results.max {|a, b| a.milliseconds <=> b.milliseconds}.milliseconds + 10
    
    clientperf_results.map do |result|
      char = 62 * result.milliseconds / max_value.to_f
      encode[char.round,1]
    end.join
  end
end