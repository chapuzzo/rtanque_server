require 'sinatra/base'
require 'json'

class Bots < Sinatra::Base

  get '/library', provides: :json do
    {
      status: :ok,
      entries: deep_find('./bots/*')
    }.to_json
  end

  def deep_find where
    Dir[where].map { |found_file|
      next {
        name: File.basename(found_file),
        type: :folder,
        contents: deep_find("#{found_file}/*")
      } if File.directory? found_file

      {
        name: File.basename(found_file),
        type: :bot,
        code: File.read(found_file)
      }
    }.sort_by { |entry| entry[:name]}
  end
end
