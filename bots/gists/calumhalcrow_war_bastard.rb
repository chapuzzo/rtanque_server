# from https://gist.github.com/calumhalcrow/6803015

class WarBastard < RTanque::Bot::Brain
  NAME = 'WAR BASTARD'
  include RTanque::Bot::BrainHelper

  @direction = true

  def tick!
    command.speed = 8

    @direction = !@direction if rand(200) < 2

    if @direction
      command.heading = sensors.heading + Math::PI / (rand(10) + 0.01)
    else
      command.heading = sensors.heading - Math::PI / (rand(10) + 0.01)
    end
    #command.radar_heading = Math::PI
    #command.turret_heading = sensors.turret_heading + Math::PI / 5.0
    #sensors.radar.each do |scanned_bot|
      ##scanned_bot: RTanque::Bot::Radar::Reflection
      #Reflection(:heading, :distance, :name)
    #end
    #
    a = sensors.radar.first
    if a and a[:name] != NAME
      command.turret_heading = a[:heading]
    else
      command.radar_heading = sensors.radar_heading + Math::PI / 2.0
    end

    command.fire(3)
  end
end
