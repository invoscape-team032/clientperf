class ClientperfController < ActionController::Base
  def index
    @uris = ClientperfUri.find(:all, :include => :clientperf_results)
  end
  
  def show
    @uri = ClientperfUri.find(params[:id], :include => :clientperf_results)
  end
  
  def reset
    if request.post?
      ClientperfUri.destroy_all
    end
    redirect_to :action => 'index'
  end
  
  def measure
    milliseconds = params[:e].to_i - params[:b].to_i rescue nil
    if milliseconds && params[:u]
      uri = ClientperfUri.find_or_create_by_uri(params[:u])
      ClientperfResult.create(:milliseconds => milliseconds, :clientperf_uri => uri)
    end
    render :nothing => true
  end
end