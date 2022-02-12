require 'sinatra'

get '/' do
    'Hello Here!'
end

get '/sleep' do
    sleep(3)
    [200, 'sleep 3']
end