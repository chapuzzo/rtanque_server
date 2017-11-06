require 'ap'
require './root'
require './quick_match'
require './matches'

run Rack::URLMap.new({
  '/' => Root,
  '/m' => Matches,
  '/qm' => QuickMatch
})
