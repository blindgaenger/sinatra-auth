require 'rubygems'
require 'facets/kernel'


module Sinatra
  module Auth

    class Basic < Rack::Auth::Basic
	    def initialize(app, *paths, &authenticator)
		    super(app, &authenticator)
		    Sinatra.options.auth_paths += paths
		    @realm = Sinatra.options.auth_realm
	    end

	    def call(env)
		    if Sinatra.options.auth_paths.include? env['REQUEST_PATH']
		      # let rack handle this
			    super(env)
		    else
		      # hand over to sinatra
			    @app.call(env)
		    end
	    end
    end

    module Helpers
      #
      # ugly, but it works
      def protect
        @app = Sinatra.application
        class << @app
          def event(method, path, options = {}, &b)
            super
            Sinatra.options.auth_paths << path         
          end
        end

        yield

        class << @app
          remove_method :event
        end
      end
      
      def auth
        
        puts "auth"
      end
    end

  end
end


#
# some default configuration
configure do
  set :auth_paths, []
  set :auth_realm, 'Sinatra Auth'
end

include Sinatra::Auth::Helpers



