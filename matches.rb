require './services/matches'
require 'sinatra/base'
require 'json'

class Matches < Sinatra::Base

  post '/create', provides: :json do
    created_match = Services::Matches.create

    ok match: created_match
  end

  post '/:match/add_bots', provides: :json do |id|
    ko unless Services::Matches.exists? id

    Services::Matches.add_bots id, params[:code]

    ok
  end

  get '/' do
    matches_list = Services::Matches.list
    erb :match_list, locals: { matches: matches_list }
  end

  get '/:match/' do |id|
    halt [404, erb('unexisting_match')] unless Services::Matches.exists? id

    erb :show_match, locals: {
      participants: Services::Matches.participants(id)
    }
  end

  get '/:match/play' do |id|
    halt [404, erb('unexisting_match')] unless Services::Matches.exists? id

    match_result = Services::Matches.play id

    erb(['<pre>', '</pre>'].join({
      status: :ok
    }.merge(match_result).to_json(
      indent: '  ',
      space: ' ',
      object_nl: "\n",
      array_nl: "\n"
    )))
  end

  helpers do
    def ok message = {}
      {status: :ok}.merge(message).to_json
    end

    def ko
      halt({
        status: :ko,
        reason: :unexisting_match
      }.to_json)
    end
  end
end
