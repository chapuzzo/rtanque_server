require 'spec_helper'

describe 'Bot Library' do
  it 'gives available bots list' do
    get '/bots/library'


    expect(parsed_response[:list].length).to eq(2)
    expect(parsed_response[:list]).to match([
      a_hash_including(bot: 'seek_and_destroy.rb'),
      a_hash_including(bot: 'camper.rb')
    ])
  end
end
