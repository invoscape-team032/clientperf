class ClientperfResult < ActiveRecord::Base
  belongs_to :clientperf_uri
  after_create :update_uri
  
  private
  
  def update_uri
    clientperf_uri.update_attribute(:updated_at, Time.now)
  end
end