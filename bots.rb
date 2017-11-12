require 'sinatra/base'
require 'json'

class Bots < Sinatra::Base

  get '/library', provides: :json do
    {
      status: :ok,
      list: Dir['./bots/**'].map { |bot_file|
        {
          bot: File.basename(bot_file),
          code: File.read(bot_file)
        }
      }
    }.to_json
  end
end
