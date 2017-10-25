require 'spec_helper'

describe 'match' do

  it 'creates one in collection' do
    fake_secure_random = double('fake_secure_random')
    allow(fake_secure_random).to receive(:uuid).and_return 'sample_uuid'
    stub_const('SecureRandom', fake_secure_random)

    post '/match/create'

    expect(App::Matches['sample_uuid']).to be_a(Hash)
  end

  it 'adds bot brains to given match' do
    fake_secure_random = double('fake_secure_random')
    allow(fake_secure_random).to receive(:uuid).and_return 'sample_uuid'
    stub_const('SecureRandom', fake_secure_random)

    post '/match/create'

    bot_definition = <<~EOB
      class MySuperBot < RTanque::Bot::Brain
        def tick!

        end
      end
    EOB

    post '/match/sample_uuid/add_bot', code: bot_definition
    expect(parsed_response[:status]).to eq('ok')

    generated_brains = App::Matches['sample_uuid'][:brains]
    generated_classes =  ::ObjectSpace.each_object(::Class).select {|k| k.name && k.name.include?('MySuperBot') }

    expect(generated_brains).to eq(generated_classes)
    expect(generated_classes.length).to eq(1)
  end
end
