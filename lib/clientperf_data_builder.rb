module ClientperfDataBuilder
  def build_data_for_chart(results, start_time, periods, period_increment)
    max = 0
    if period_increment == :days && ActiveRecord::Base.default_timezone == :utc
      start_time = start_time.to_datetime.change(:offset => 0).to_time
    end
    padded_results = (0..periods).map do |delta|
      time_period = start_time + delta.send(period_increment)
      data = get_data_or_pad(time_period, results)
      max = data if data && data > max
      [time_period, data]
    end
    [padded_results, max]
  end
  
  private
  
  def get_data_or_pad(point, results)
    data = results.detect {|p,d| point == p.to_time(ActiveRecord::Base.default_timezone)}
    data ? data[1].to_i : 0
  end
end