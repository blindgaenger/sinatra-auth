$LOAD_PATH.unshift "../lib"

require 'rubygems'
require 'sinatra'
require 'auth'


use Sinatra::Auth::Basic do |username, password|
	puts "#{username} : #{password}"
  username == 'user' && password = 'pass'
end

configure do
#  set :run, false
  set :port, 9393

  set :auth_paths, ['/auth_direct']
  set :auth_realm, 'My Application'
end


get '/free' do
	'<h1>Free</h1>'
end

get '/auth_direct' do
  '<h1>Auth</h1>'
end

get '/auth_method' do
  '<h1>Auth</h1>'
end

auth do
  get '/auth_block' do
    p "req: #{@request.inspect}"
    p "res: #{@response.inspect}"    
    '<h1>Auth</h1>'
  end
end

get '/free_still' do
	'<h1>Free</h1>'
end


p "all paths:  #{Sinatra.application.events[:get][1..-1].map {|e| e.path}.inspect}"
p "auth_paths: #{Sinatra.options.auth_paths.inspect}"

p Sinatra.application.pipeline
