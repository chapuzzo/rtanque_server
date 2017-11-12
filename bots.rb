require 'sinatra/base'
require 'json'

class Bots < Sinatra::Base

  get '/library', provides: :json do
    {
      status: :ok,
      bots: Dir['./bots/**'].map { |bot_file|
        {
          name: File.basename(bot_file),
          code: File.read(bot_file)
        }
      }
    }.to_json
  end
end
