require 'securerandom'
require 'sinatra/base'
require 'rtanque'
require 'json'
require 'ap'

class QuickMatch < Sinatra::Base

  ImportedBots = Module.new

  get '/' do
    erb :quick_match, layout: false
  end

  post '/' do
    classes = extract_class_from(params[:code], Object)
    ap classes

    bot_brain_classes = get_descendants_of_class(RTanque::Bot::Brain)
    ap bot_brain_classes

    brains_to_add = bot_brain_classes.select do |brain|
      classes.include? brain
    end

    match = RTanque::Match.new(RTanque::Arena.new(500, 500), 10000)

    bots = brains_to_add.map do |brain|
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
      ap :match_ended_gracefully
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

    ImportedBots.constants.each do |constant|
      ap :removing
      ap constant
      ImportedBots.send(:remove_const, constant)
    end
    ap ImportedBots.constants

    erb(['<pre>', '</pre>'].join({
      status: :ok,
      survivors: survivors
    }.to_json(
      indent: '  ',
      space: ' ',
      object_nl: "\n",
      array_nl: "\n"
    )), layout: false)
  end

  helpers do
    def extract_class_from io, under
      current_object_space = get_descendants_of_class(under)
      ImportedBots.module_eval(io)
      get_descendants_of_class(under) - current_object_space
    end

    def get_descendants_of_class(klass)
      ::ObjectSpace.each_object(::Class).select {|k| k < klass }
    end
  end
end

