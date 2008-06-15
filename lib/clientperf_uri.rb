class ClientperfUri < ActiveRecord::Base
  has_many :clientperf_results, :dependent => :delete_all

  def result_average
    @result_average ||= clientperf_results.inject(0) {|sum, result| sum += result.milliseconds; next sum} / clientperf_results.size.to_f
  end
end