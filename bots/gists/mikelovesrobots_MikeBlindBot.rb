# from https://gist.github.com/mikelovesrobots/1a2b06c21c03a71483c8924c1abcf8d9

class MikeBlindBot < RTanque::Bot::Brain
  NAME = 'MikeBlindBot2'
  include RTanque::Bot::BrainHelper

  TURRET_FIRE_RANGE = RTanque::Heading::ONE_DEGREE * 1.0

  def tick!
    ## main logic goes here
    @direction_degrees ||= 0
    if self.sensors.position.on_top_wall?
      @direction_degrees = -180
    elsif self.sensors.position.on_bottom_wall?
      @direction_degrees = 0
    end

    self.command.speed = MAX_BOT_SPEED
    self.command.heading = RTanque::Heading.new_from_degrees(@direction_degrees)

    if (target = self.nearest_target)
      self.fire_upon(target)
    else
      self.detect_targets
    end
    self.command.fire(MIN_FIRE_POWER)
  end

  def fire_upon(target)
    self.command.radar_heading = target.heading
    self.command.turret_heading = target.heading
  end

  def nearest_target
    self.sensors.radar.min { |a,b| a.distance <=> b.distance }
  end

  def detect_targets
    self.command.radar_heading = self.sensors.radar_heading + MAX_RADAR_ROTATION
    self.command.turret_heading = self.sensors.heading + RTanque::Heading::HALF_ANGLE
  end
end
