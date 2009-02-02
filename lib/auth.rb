require 'rubygems'
require 'facets/kernel'


module Sinatra
  module Auth

    class Basic < Rack::Auth::Basic
	    def initialize(app, *paths, &authenticator)
		    super(app, &authenticator)
        Basic.add_auth_paths(paths)
	    end

	    def call(env)
		    if Basic.auth_paths.include? env['PATH_INFO']
		      # let rack handle this
		      @realm = Basic.auth_realm
			    super(env)
		    else
		      # hand over to sinatra
			    @app.call(env)
		    end
	    end

      def self.auth_realm
        Sinatra.options.auth_realm || 'Sinatra Auth'      
      end

	    def self.auth_paths
        Sinatra.options.auth_paths || []	    
	    end
	    
	    def self.add_auth_paths(*paths)
        Sinatra.options.auth_paths = (auth_paths << paths).flatten!
	    end
    end

    module Helpers
      #
      # ugly, but it works
      def auth
        @app = Sinatra.application
        class << @app
          def event(method, path, options = {}, &b)
            super
            Basic.add_auth_paths(path)
          end
        end

        yield

        class << @app
          remove_method :event
        end
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



