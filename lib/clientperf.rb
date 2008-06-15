module Clientperf
  
  class << self
    def load
      if supported_rails_version?
        require 'dispatcher'
        Dispatcher.to_prepare :clientperf_route do
          ActionController::Routing::Routes.add_route '/clientperf', :controller => 'clientperf', :action => 'index'
          ActionController::Routing::Routes.add_route '/clientperf/measure.gif', :controller => 'clientperf', :action => 'measure'
          ActionController::Routing::Routes.add_route '/clientperf/:id', :controller => 'clientperf', :action => 'show'
          3.times do
            route = ActionController::Routing::Routes.routes.pop
            ActionController::Routing::Routes.routes.unshift(route)
          end
        end
        ActionController::Base.append_view_path(File.dirname(__FILE__) << "/../views")
        hook_into_response
      end
    end
    
    def version
      "0.0.1"
    end
    
    private
    
    def supported_rails_version?
      version = Rails::VERSION rescue nil
      return true unless version
      if version::MAJOR < 2
        STDERR.puts "[clientperf] rails < 2.0 not supported. skipping load."
        false
      else
        true
      end
    end
    
    def hook_into_response
      ActionController::Base.send! :include, ExtendActionController
    end
  end
end