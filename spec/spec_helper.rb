require 'rack/test'
require 'rspec'
require 'ap'

ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', 'app')

def app
  $app ||= Rack::Builder.parse_file(File.expand_path('../../config.ru', __FILE__)).first
end

def parsed_response
  Sinatra::IndifferentHash[JSON last_response.body]
end

def url_query_to_hash uri
  require 'uri'
  require 'cgi'
  uri = URI.parse(uri)
  Hash[CGI.parse(uri.query).map { |key,values|
    [key.to_sym, values[0]||true]
  }]
end

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

end
