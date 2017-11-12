# from http://www.rubyexample.com/snippet/ruby/vampirerb_mando_ruby

class Vampire < RTanque::Bot::Brain
  NAME = 'VAMPIRE'
  include RTanque::Bot::BrainHelper

  attr_accessor :mah_bot

  def tick!
    @mah_bot = nil
    # Find myself
    unless @mah_bot
      ObjectSpace.each_object(RTanque::Bot) do |b|
        if b.name == NAME
          @mah_bot = b
          next
        end
      end
    end

    # Find the other suckers :)
    ObjectSpace.each_object(RTanque::Bot) do |b|
      next if b == mah_bot
      suck(b)
    end

    # Go ahead and try and shoot some stuffs
    find_nearest_guy
    chase_and_attack
  end

  private

    def find_nearest_guy
      scan
      @nearest = sensors.radar.first
    end

    def chase_and_attack
      if sensors.position.on_wall?
        command.heading = sensors.heading + RTanque::Heading::HALF_ANGLE
      end

      if @nearest
        command.heading = @nearest.heading
        command.radar_heading = @nearest.heading
        command.turret_heading = @nearest.heading
      end
      command.speed = MAX_BOT_SPEED
      command.fire(MAX_FIRE_POWER)

    end

    def scan
      command.radar_heading = sensors.radar_heading + MAX_RADAR_ROTATION
    end

    def suck(b)
      health_to_steal = 0.3
      @mah_bot.health += health_to_steal
      b.health -= health_to_steal
    end
end
