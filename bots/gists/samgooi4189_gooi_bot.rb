# from https://gist.github.com/samgooi4189/f6481e33f0f78e686b64bdd8fb0b2e5a

class GooiBot < RTanque::Bot::Brain
  NAME = 'gooi_bot'
  include RTanque::Bot::BrainHelper

  MAX_RAND_DIVISION = 10.0

  def tick!
    ## main logic goes here
    @current_heading ||= sensors.heading

    command.speed = 2.0
    command.heading = @current_heading

    if sensors.position.on_wall?
      @current_heading = random_turn + RTanque::Heading.new(Math::PI/2.0)
    elsif enemy_detected
      command.fire_power = 2.0
      command.turret_heading = @enemy.heading
      command.radar_heading = @current_heading
      @current_heading = random_turn + RTanque::Heading.new(Math::PI/2.0)
    end

    # use self.sensors to detect things
    # See http://rubydoc.info/github/awilliams/RTanque/master/RTanque/Bot/Sensors

    # use self.command to control tank
    # See http://rubydoc.info/github/awilliams/RTanque/master/RTanque/Bot/Command

    # self.arena contains the dimensions of the arena
    # See http://rubydoc.info/github/awilliams/RTanque/master/frames/RTanque/Arena
  end

  def random_range
    rand(1..MAX_RAND_DIVISION) / 1.0
  end

  def random_turn
    sensors.heading + RTanque::Heading.new(Math::PI/random_range)
  end

  def enemy_detected
    @enemy = sensors.radar.find { |reflection|  reflection }
  end


end
