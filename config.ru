require 'ap'
require './root'
require './quick_match'
require './matches'
require './bots'

run Rack::URLMap.new({
  '/' => Root,
  '/m' => Matches,
  '/qm' => QuickMatch,
  '/bots' => Bots
})
