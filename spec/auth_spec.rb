$LOAD_PATH.unshift "spec"

require 'rubygems'
require 'sinatra'
require 'sinatra/test/rspec'
require 'lib/auth'
require 'base64'

USERNAME = 'user'
PASSWORD = 'pass'
HTTP_AUTH_VALID = {"HTTP_AUTHORIZATION" => "Basic #{Base64.encode64 "#{USERNAME}:#{PASSWORD}"}"}
HTTP_AUTH_INVALID  = {"HTTP_AUTHORIZATION" => "Basic #{Base64.encode64 "eve:picklock"}"}

def response_should_be(status, body)
  @response.status.should == status
  @response.body.should == body
end

describe Sinatra::Auth do

  before(:each) do
    Sinatra.application = nil
    @app = Sinatra.application
  end    

  describe "configuration" do

    it "routes can be set in the middleware definiton" do
      use Sinatra::Auth::Basic, ['/private'] do |username, password|
        username == 'USER' && password = 'PASS'
      end
    
      get '/public' do
        'free'
      end
      
      get '/private' do
        'secret'
      end

      # force rack to instantiate its middleware
      get_it '/private'

      Sinatra::Auth::Basic.auth_paths.should == ["/private"]
    end

    it "routes can be set in the configure block" do
      @app.configure do
        set :auth_paths, ['/private']
      end
      
      get '/public' do
        'free'
      end
      
      get '/private' do
        'secret'
      end

      Sinatra::Auth::Basic.auth_paths.should == ["/private"]
    end

    it "routes can be set with the protect helper" do
      configure do
        auth :basic do
        end
      end
    
      get '/public' do
        'free'
      end

      protect do
        get '/private' do
          'secret'
        end

        get '/another_private' do
          'another secret'
        end
      end

      get '/another_public' do
        'another free'
      end
      
      protect do
        get '/still_private' do
          'still secret'
        end
      end

      get '/still_public' do
        'still free'
      end

      Sinatra::Auth::Basic.auth_paths.should == ["/private", "/another_private", "/still_private"]
    end
    
    it "should fail if no auth method was configured" do
      lambda {
        protect do
          get '/private' do
            'secret'
          end
        end
      }.should raise_error(RuntimeError)
    end
    
  end #configuration
  
  
  describe "authorization" do

    it "should authenticate using the defined authenticator" do
      @called = false

      configure do
        auth :basic do |username, password|
          @called = true
          username == USERNAME && password = PASSWORD
        end
      end

      protect do
        get '/private' do
          'secret'
        end
      end
      
      get_it '/private'
      response_should_be 401, ""
      @called.should == false

      get_it '/private', :env => HTTP_AUTH_INVALID
      response_should_be 401, ""
      @called.should == true

      get_it '/private', :env => HTTP_AUTH_VALID
      response_should_be 200, "secret"
      @called.should == true
    end    


    it "should authenticate only the protected routes" do
      configure do
        auth :basic do |username, password|
          username == USERNAME && password = PASSWORD
        end
      end    
    
      get '/public' do
        'free'
      end

      protect do
        get '/private' do
          'secret'
        end

        get '/another_private' do
          'another secret'
        end
      end

      get '/another_public' do
        'another free'
      end
      
      protect do
        get '/still_private' do
          'still secret'
        end
      end

      get '/still_public' do
        'still free'
      end
      
      get_it '/public'
      response_should_be 200, "free"
    
      get_it '/private'
      response_should_be 401, ""
    
      get_it '/another_private'
      response_should_be 401, ""

      get_it '/another_public'
      response_should_be 200, "another free"

      get_it '/still_private'
      response_should_be 401, ""

      get_it '/still_public'
      response_should_be 200, "still free"
    end

    it "should work after reloading in development" do
      app_file = "reloadable.rb"
      load app_file

      get_it '/public'
      response_should_be 200, "free"
    
      get_it '/private'
      response_should_be 401, ""

      Sinatra.options.app_file = app_file
      Sinatra.application.reload!

      get_it '/public'
      response_should_be 200, "free"
    
      get_it '/private'

      pending do
        response_should_be 401, ""
      end
    end

  end #authentication

end
