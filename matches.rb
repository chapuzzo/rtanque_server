require 'securerandom'
require 'sinatra/base'
require 'rtanque'
require 'json'
require 'ap'

class Matches < Sinatra::Base

  Matches = {}

  post '/create', provides: :json do
    created_match = {
      brains: []
    }

    match_name = SecureRandom.uuid

    Matches[match_name] = created_match

    {
      status: :ok,
      match: match_name
    }.to_json
  end

  post '/:match/add_bots', provides: :json do |id|
    return {
      status: :ko,
      reason: :unexisting_match
    }.to_json if Matches[id].nil?

    match = Matches[id]

    classes = class_diff(params[:code], Object, Class.new)
    bot_brain_classes = get_descendants_of_class(RTanque::Bot::Brain)

    new_brains = (bot_brain_classes - match[:brains]).select do |brain|
      classes.include? brain
    end

    match[:brains].push(*(new_brains))

    {
      status: :ok
    }.to_json
  end

  get '/' do
    matches_list = Matches.map { |id, match|
      {
        id: id,
        participants: participant_names(match)
      }
    }

    erb :match_list, locals: { matches: matches_list }
  end

  get '/:match/' do |id|
    halt [404, erb('unexisting_match')] if Matches[id].nil?

    erb :show_match, locals: {
      participants: participant_names(Matches[id])
    }
  end

  get '/:match/play' do |id|
    halt [404, erb('unexisting_match')] if Matches[id].nil?

    @match_time = 0

    brains = Matches[id][:brains]

    match = RTanque::Match.new(RTanque::Arena.new(500, 500), 10000)

    bots = brains.map do |brain|
      RTanque::Bot.new_random_location(match.arena, brain)
    end

    match_thread = Thread.new do
      bots.each do |bot|
        bot.brain.instance_variable_set(:@friendly_fire, true)
        match.add_bots(bot)
      end

      match.start
    end

    watchdog = Thread.new do
      60.times do
        Thread.exit unless match_thread.alive?
        @match_time += 1
        sleep 1
      end

      match_thread.kill if match_thread.alive?
    end

    watchdog.join

    survivors = match.bots.map do |bot|
      {
        name: bot.name,
        health: bot.health.round
      }
    end

    erb(['<pre>', '</pre>'].join({
      status: :ok,
      survivors: survivors,
      ticks: match.ticks,
      time: @match_time
    }.to_json(
      indent: '  ',
      space: ' ',
      object_nl: "\n",
      array_nl: "\n"
    )))
  end

  helpers do
    def class_diff from, under, to
      current_object_space = get_descendants_of_class(under)
      to.class_eval(from)
      get_descendants_of_class(under) - current_object_space
    end

    def get_descendants_of_class(klass)
      ::ObjectSpace.each_object(::Class).select {|k| k < klass }
    end

    def participant_names match
      match[:brains].map { |brain| name_that_bot brain }
    end

    def name_that_bot brain
      brain.const_defined?(:NAME) && brain.const_get(NAME) || brain.name.split('::').last
    end
  end
end
