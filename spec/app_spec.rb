require 'spec_helper'

describe 'Matches' do

  let(:fake_secure_random) {
    double('fake_secure_random')
  }

  it 'get created in collection' do
    stub_const('SecureRandom', fake_secure_random)

    create_match fake_secure_random, 'sample_uuid'

    expect(App::Matches['sample_uuid']).to be_a(Hash)
    expect(App::Matches['sample_uuid']).to eq(brains: [])
  end

  it 'can be added bot brains' do
    stub_const('SecureRandom', fake_secure_random)

    create_match fake_secure_random, 'sample_uuid'

    bot_definition = <<~EOB
      class MySuperBot < RTanque::Bot::Brain
        def tick!; end
      end
    EOB

    add_bot_to_match bot_definition, 'sample_uuid'

    generated_brains = App::Matches['sample_uuid'][:brains]

    expect(generated_brains.length).to eq(1)
  end

  it 'adds given bot to selected match' do
    stub_const('SecureRandom', fake_secure_random)

    bot_definition = <<~EOB
      class MySuperBot < RTanque::Bot::Brain
        def tick!; end
      end
    EOB

    create_match fake_secure_random, 'sample_uuid'
    add_bot_to_match bot_definition, 'sample_uuid'

    generated_brains = App::Matches['sample_uuid'][:brains]
    expect(generated_brains.length).to eq(1)

    create_match fake_secure_random, 'other_uuid'
    add_bot_to_match bot_definition, 'other_uuid'

    generated_brains = App::Matches['other_uuid'][:brains]
    expect(generated_brains.length).to eq(1)
  end

  def add_bot_to_match bot_definition, match
    post "/matches/#{match}/add_bots", code: bot_definition
    expect(parsed_response[:status]).to eq('ok')
  end

  def create_match id_generator, desired_id
    allow(id_generator).to receive(:uuid).and_return desired_id

    post '/matches/create'
    expect(parsed_response[:status]).to eq('ok')
  end
end
