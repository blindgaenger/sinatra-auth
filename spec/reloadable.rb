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
end
      
