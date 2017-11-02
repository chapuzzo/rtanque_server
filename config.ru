require 'ap'
require './quick_match'
require './app'

map '/quick_match' do
  run QuickMatch
end

map '/' do
  run App
end
