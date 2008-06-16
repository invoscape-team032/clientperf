class ClientperfController < ActionController::Base
  def index
    @uris = ClientperfUri.find(:all, :include => :clientperf_results)
  end
  
  def show
    @uri = ClientperfUri.find(params[:id], :include => :clientperf_results)
  end
  
  def reset
    if request.post?
      if params[:id]
        ClientperfUri.destroy(params[:id])
      else
        ClientperfUri.destroy_all
      end
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
  
  private
  
  def authenticate
    config = ClientperfConfig.new
    logger.info "yo"
    if config.has_auth?
      authenticate_or_request_with_http_basic do |user_name, password|
        user_name == config[:username] && password == config[:password]
      end
    end
  end
end