# from https://gist.github.com/jrmhaig/e3e396912c55b8cdf16d

class SpiralBot < RTanque::Bot::Brain
  NAME = 'SpiralBot'
  include RTanque::Bot::BrainHelper

  def initialize(opts)
    @opponents = {}
    @target = nil
    super
  end

  def tick!
    command.heading = RTanque::Heading.new(RTanque::Heading::EAST)
    command.speed = 8

    sensors.radar.each do |reflection|
      puts "#{sensors.ticks}: #{reflection.name} #{reflection.distance} #{reflection.heading}"
      @opponents[reflection.name] = {
        angle: reflection.heading,
        distance: reflection.distance,
        age: 0
      }
      @target = reflection.name
      command.speed = 3
    end
    @opponents.each do |tank, last_seen|
      last_seen[:age] += 1
    end

    if @target.nil?
      command.radar_heading = sensors.radar_heading + (RTanque::Heading::ONE_DEGREE * 30)
    else
      command.heading = @opponents[@target][:angle] +
          RTanque::Heading::ONE_DEGREE * ( 400 - @opponents[@target][:distance] ) / 100 +
          RTanque::Heading::HALF_ANGLE / 2.0
      command.turret_heading = @opponents[@target][:angle]
      command.radar_heading = @opponents[@target][:angle]
      command.fire(MIN_FIRE_POWER)
      if @opponents[@target][:age] > 50
        @target = nil
        command.speed = 8
      end
    end
  end
end
