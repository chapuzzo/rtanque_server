# from https://gist.github.com/alterisian/b35e4f9d3ea7ea432ccc

class Panther < RTanque::Bot::Brain
  NAME = 'Survival Panther'
  include RTanque::Bot::BrainHelper

  def tick!
    command.radar_heading = sensors.radar_heading + (RTanque::Heading::ONE_DEGREE * 30)

    at_tick_interval(25) do
      print_stats
    end

    at_tick_interval(2) do

      new_direction = sensors.heading - (RTanque::Heading::ONE_DEGREE * 45)

      if new_direction < 0
         new_direction += (360 * RTanque::Heading::ONE_DEGREE)
      end

      command.heading = RTanque::Heading.new(new_direction)
      command.speed = 4

      if sensors.radar.count > 0
        other_bot = sensors.radar.first
        #puts "***Other bot: #{other_bot.name}, #{other_bot.heading.inspect} #{other_bot.distance}"
        command.turret_heading = other_bot.heading
      else
        command.turret_heading = sensors.heading - (180 *RTanque::Heading::ONE_DEGREE )
        #command.turret_heading = command.turret_heading + (RTanque::Heading::ONE_DEGREE * 45)
      end

      command.fire_power = 3
    end

  end

  def print_stats
      puts "Tick ##{sensors.ticks}!"
      puts " Gun Energy: #{sensors.gun_energy}"
      puts " Health: #{sensors.health}"
      puts " Position: (#{sensors.position.x}, #{sensors.position.y})"
      puts sensors.position.on_wall? ? " On Wall" : " Not on wall"
      puts " Speed: #{sensors.speed}"
      puts " Heading: #{sensors.heading.inspect} "
      puts " Turret Heading: #{sensors.turret_heading.inspect}"
      puts " Radar Heading: #{sensors.radar_heading.inspect}"
      puts " Radar Reflections (#{sensors.radar.count}):"
      sensors.radar.each do |reflection|
        puts "  #{reflection.name} #{reflection.heading.inspect} #{reflection.distance}"
      end
  end

end
