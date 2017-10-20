require 'sinatra/base'
require 'rtanque'
require 'json'
require 'ap'

ImportedBots = Module.new

class App < Sinatra::Base
  get '/' do
    erb :index
  end

  post '/quick_match' do
    classes = extract_class_from(params[:code], Object)
    ap classes

    bot_brain_classes = get_descendants_of_class(RTanque::Bot::Brain)
    ap bot_brain_classes

    match = RTanque::Match.new(RTanque::Arena.new(500, 500), 10000)

    bots = bot_brain_classes.map do |brain|
      RTanque::Bot.new_random_location(match.arena, brain)
    end

    match_thread = Thread.new do
      class File
        def method_missing name, *args, &block
          ap :you_re_trying_to_be_meany
          # raise StandardError.new 'Being bad'
        end
      end

      bots.each do |bot|
        ap bot
        bot.brain.instance_variable_set(:@friendly_fire, true)
        match.add_bots(bot)
      end

      match.start
      ap :match_ended
    end

    watchdog = Thread.new do
      15.times do

        Thread.exit unless match_thread.alive?
        sleep 1
      end

      ap :timed_out
      match_thread.kill if match_thread.alive?

      ap match.ticks
    end

    watchdog.join


    survivors = match.bots.map do |bot|
      puts "#{bot.name} [#{bot.health.round}]"
      {
        name: bot.name,
        health: bot.health.round
      }
    end

    # ImportedBots.constants.each do |constant|
    #   ImportedBots.send(:remove_const, constant)
    # end

    {
      status: :ok,
      survivors: survivors
    }.to_json
  end

  helpers do
    def extract_class_from io, under
      current_object_space = get_descendants_of_class(under)
      ImportedBots.class_eval(io)
      get_descendants_of_class(under) - current_object_space
    end

    def get_descendants_of_class(klass)
      ::ObjectSpace.each_object(::Class).select {|k| k < klass }
    end
  end

end
