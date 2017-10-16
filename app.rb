require 'sinatra/base'

class App < Sinatra::Base
  get '/' do
    erb :index
  end

  post '/' do
    ap params
    # [200, 'ok']
    eval params[:code]
  end
end

