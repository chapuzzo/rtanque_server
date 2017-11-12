# from http://www.rubyexample.com/snippet/ruby/lirenrb_lirenyeo_ruby

class Liren < RTanque::Bot::Brain
  NAME = 'Liren'
  include RTanque::Bot::BrainHelper
 
  def tick!
    command.speed = RTanque::Bot::MAX_SPEED
    command.heading = RTanque::Heading.new(RTanque::Heading::EAST)
    command.radar_heading = RTanque::Heading::ONE_DEGREE * Random.rand(80)
    command.turret_heading = RTanque::Heading::ONE_DEGREE * Random.rand(80)
    command.fire(RTanque::Bot::MIN_FIRE_POWER)
 
    if (!defined?(@direction))
      @direction = 0
      @previousTargetX = 0
      @previousTargetY = 0
    end
 
 
    onWall = false
    if (sensors.position.on_top_wall?)
        command.heading = RTanque::Heading::SOUTH
        command.turret_heading = RTanque::Heading::NORTH
        onWall = true
    elsif (sensors.position.on_bottom_wall?)
        command.heading = RTanque::Heading::NORTH
        command.turret_heading = RTanque::Heading::SOUTH
        onWall = true
    elsif (sensors.position.on_left_wall?)
        command.heading = RTanque::Heading::EAST
        command.turret_heading = RTanque::Heading::WEST
        onWall = true
    elsif (sensors.position.on_right_wall?)
        command.heading = RTanque::Heading::WEST
        command.turret_heading = RTanque::Heading::EAST
        onWall = true
    end
 
    if (onWall)
      if (sensors.heading.delta(command.heading) > 0)
        @direction = 1
      else
        @direction = -1
      end
    else
        if (Random.rand(80) < 1)
            @direction = 0 - @direction
        end
 
        command.heading = sensors.heading + @direction * RTanque::Heading::ONE_DEGREE * 5.0
    end
  end
end