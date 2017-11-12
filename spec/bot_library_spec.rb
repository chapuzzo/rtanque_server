require 'spec_helper'

describe 'Bot Library' do
  it 'gives available bots list' do
    get '/bots/library'


    expect(parsed_response[:bots].length).to eq(2)
    expect(parsed_response[:bots]).to match([
      a_hash_including(name: 'seek_and_destroy.rb'),
      a_hash_including(name: 'camper.rb')
    ])
  end
end
