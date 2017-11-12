# from https://gist.github.com/cmolenda/6d1c9a9566468af42b52

# MAX_BOT_SEED to go fast
class GameOn < RTanque::Bot::Brain
  NAME = 'GameOn'
  include RTanque::Bot::BrainHelper

  TURRET_FIRE_RANGE = RTanque::Heading::ONE_DEGREE * 1.0
  SWITCH_CORNER_TICK_RANGE = (600..1000)
  def tick!
    movable
    if (target = nearest_target)
      fire_upon(target)
    else
      detect_targets
    end
    command.speed = MAX_BOT_SPEED
  end

  HEADINGS = { north: RTanque::Heading::NORTH, south: RTanque::Heading::SOUTH }

  def movable
    @current_heading ||= HEADINGS[:north]
    # binding.pry
    if sensors.position.on_top_wall?
      @current_heading = HEADINGS[:south]
    elsif sensors.position.on_bottom_wall?
      @current_heading = HEADINGS[:north]
    end
    command.heading = @current_heading
  end

  def fire_upon(target)
    command.radar_heading = target.heading
    command.turret_heading = target.heading
    if sensors.turret_heading.delta(target.heading).abs < TURRET_FIRE_RANGE
      command.fire(MAX_FIRE_POWER)
    end
  end

  def nearest_target
    sensors.radar.min { |a,b| a.distance <=> b.distance }
  end

  def detect_targets
    command.radar_heading = sensors.radar_heading + MAX_RADAR_ROTATION
    command.turret_heading = sensors.heading + RTanque::Heading::HALF_ANGLE
  end
end
