require 'securerandom'
require 'rtanque'
require 'ap'

module Services
  class Matches
    Matches = {}

    class << self
      def create
        created_match_params = {
          brains: []
        }

        match_name = SecureRandom.uuid

        Matches[match_name] = created_match_params

        match_name
      end

      def exists? id
        !Matches[id].nil?
      end

      def add_bots id, code
        match = Matches[id]

        classes = class_diff(code, Object, Class.new)
        bot_brain_classes = get_descendants_of_class(RTanque::Bot::Brain)

        new_brains = (bot_brain_classes - match[:brains]).select do |brain|
          classes.include? brain
        end

        match[:brains].concat(new_brains)
      end

      def list
        Matches.map do |id, match|
          {
            id: id,
            participants: participant_names(match)
          }
        end
      end

      def participants id
        participant_names(Matches[id])
      end

      def play id, seed = Kernel.srand
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

        {
          survivors: survivors,
          ticks: match.ticks,
          time: @match_time
        }
      end

      private
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
end
