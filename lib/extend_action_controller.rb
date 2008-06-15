module ExtendActionController
  def self.included(base)
    base.alias_method_chain :process, :clientperf
  end
  
  def process_with_clientperf(request, response, *args, &block)
    result = process_without_clientperf(request, response, *args, &block)
    if add_clientperf?(request, response)
      add_clientperf_to(response)
    end
    result
  end
  
  def add_clientperf_to(response)
    if response.body =~ /<html[^>]*?>/im
      replacement = %q(\1
        <script type='text/javascript'>
          var clientPerfStart = (new Date()).getTime();
          var clientPerf = function() {
            var attach = function(instance, eventName, listener) {
            	var listenerFn = listener;
            	if (instance.addEventListener) {
            		instance.addEventListener(eventName, listenerFn, false);
            	}
            	else if (instance.attachEvent) { // Internet explorer
            		listenerFn = function() {
            	    	listener(window.event);
            		};
            		instance.attachEvent("on" + eventName, listenerFn);
            	}
            	else {
            	    // I could do some further attachment here, if I wanted too. for older browsers
            	    // ex: instance['on' + eventName] = listener;
            		throw new Error("Event registration not supported");
            	}
            };
            
            var endRun = function() {
              var clientPerfEnd = (new Date()).getTime();
              var img = document.createElement('img');
              img.src = '/clientperf/measure.gif?b=' + clientPerfStart + '&e=' + clientPerfEnd + '&u=' + location.href;
              document.body.appendChild(img);
            };
            
            try {
                attach(window, 'load', endRun);
            }
            catch(e) {
                window.onload = endRun;
            }
          }
          clientPerf();
        </script>
      )
      
      response.body.sub!(/(<html[^>]*?>)/im, replacement)
      response.headers["Content-Length"] = response.body.size
    end
  end
  
  def add_clientperf?(request, response)
    !request.xhr? && response.content_type && response.content_type.include?('html') && 
      response.body && response.headers['Status'] && response.headers['Status'].include?('200') && 
      controller_name != 'clientperf'
  end
end