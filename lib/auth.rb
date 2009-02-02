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
        Sinatra.options.auth_paths = (auth_paths << paths.flatten).flatten.uniq
	    end
    end

    module Helpers
    
      def auth(method, realm=nil, &authenticator)
        Sinatra.options.auth_realm = realm
        raise "please define a block as authenticator method" if authenticator.nil?
        use Basic, &authenticator
        @__configured_auth__ = true
      end

      #
      # ugly, but it works
      def protect(&block)
        raise "authorize wasn't configured" unless @__configured_auth__

        class << Sinatra.application
          def event(method, path, options = {}, &b)
            super
            Basic.add_auth_paths(path)
          end
        end
        
        yield

        class << Sinatra.application
          remove_method :event
        end
      end
      
    end

  end
end

include Sinatra::Auth::Helpers

