# from https://gist.github.com/jackfern/6b7aaf1dd4d0dc5a6fce29233e7dd82e

class TestBot < RTanque::Bot::Brain
  NAME = 'test_bot'
  include RTanque::Bot::BrainHelper

  def tick!
    # firing
    # movement
    onWall = false
    if (sensors.position.on_top_wall?)
        command.heading = RTanque::Heading::SOUTH
        onWall = true
    elsif (sensors.position.on_bottom_wall?)
        command.heading = RTanque::Heading::NORTH
        onWall = true
    elsif (sensors.position.on_left_wall?)
        command.heading = RTanque::Heading::EAST
        onWall = true
    elsif (sensors.position.on_right_wall?)
        command.heading = RTanque::Heading::WEST
        onWall = true
    end
    # radar
    command.speed = MAX_BOT_SPEED
    command.fire(MAX_FIRE_POWER)

    at_tick_interval(10) do
      command.heading = RTanque::Heading::rand
    end
  end

end
