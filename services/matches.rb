require 'securerandom'
require 'rtanque'
require 'ap'

module Services
  class Matches
    MAX_MATCH_TICKS = 10000
    MAX_MATCH_TIME = 60
    CHECK_INTERVAL = 1

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

        classes = get_definitions(code, Object, Module.new)
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
        brains = Matches[id][:brains]

        match = RTanque::SerializableMatch.new(RTanque::Match.new(RTanque::Arena.new(500, 500), MAX_MATCH_TICKS))

        match.instance_exec {
          @scenes = []

          def tick
            @match.tick
            @scenes << self.snapshot
          end

          def start
            self.tick until self.finished?
          end
        }

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
          (MAX_MATCH_TIME/CHECK_INTERVAL).round.times do
            sleep CHECK_INTERVAL
            next if match_thread.alive?
            Thread.exit
          end

          match_thread.kill
        end

        watchdog.join

        {
          arena: match.arena.to_h,
          scenes: match.instance_exec { @scenes }
        }
      end

      private
        def get_definitions from, under, holder
          current_object_space = get_descendants_of_class(under)
          holder.instance_eval(from)
          get_descendants_of_class(under) - current_object_space
        end

        def get_descendants_of_class parent
          ::ObjectSpace.each_object(::Class).select {|k| k < parent }
        end

        def participant_names match
          match[:brains].map { |brain| name_that_bot brain }
        end

        def name_that_bot brain
          brain.const_defined?(:NAME) && brain.const_get(:NAME) || brain.name.split('::').last
        end
    end
  end
end
