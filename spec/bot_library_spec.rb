require 'spec_helper'

describe 'Bot Library' do
  it 'gives available bots list' do
    get '/bots/library'

    expect(parsed_response[:entries]).to match([
      a_hash_including(name: 'gists'),
      a_hash_including(name: 'rubyexamples'),
      a_hash_including(name: 'stock')
    ])

    expect(parsed_response[:entries].last[:contents]).to match([
      a_hash_including(name: 'camper.rb'),
      a_hash_including(name: 'seek_and_destroy.rb')
    ])
  end
end
