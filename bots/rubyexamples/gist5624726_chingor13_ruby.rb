# from http://www.rubyexample.com/snippet/gist5624726_chingor13_ruby

class KageBunshin < RTanque::Bot::Brain
  NAME = 'kage_bunshin'
  include RTanque::Bot::BrainHelper

  def tick!
    hide_from_sensors!

    pick_spot!
    turn_to_spot!
    acquire_target!
    determine_target_vectors!
    fire_when_ready!
  end

  protected

  def hide_from_sensors!
    return if @hidden_from_sensors
    my_name = NAME
    RTanque::Bot::Sensors.send(:define_method, :radar) do
      self["radar"].map do |reflection|
        if reflection.name == my_name
          if reflection.distance > 400
            reflection.heading += 6 * RTanque::Heading::ONE_DEGREE
          else
            reflection.heading += 10 * RTanque::Heading::ONE_DEGREE
          end
        end
        reflection
      end
    end
    @hidden_from_sensors = true
  end

  def at_spot?
    return false if @spot.nil?

    self.sensors.position.within_radius?(@spot, 10)
  end

  def time_for_new_spot?
    return false if @tick_count.nil?

    @tick_count > 60 && rand(4) <= 1
  end

  def pick_spot!
    if at_spot? || time_for_new_spot?
      @spot = nil
    end
    if @spot.nil?
      @tick_count = 0
      @spot = RTanque::Point.new(rand(self.arena.width), rand(self.arena.height), self.arena)
    end
    @tick_count += 1
  end

  def turn_to_spot!
    self.command.heading = self.sensors.position.heading(@spot)

    distance_to_spot = self.sensors.position.distance(@spot)
    if distance_to_spot < 25
      self.command.speed = 1
    elsif distance_to_spot < 50
      self.command.speed = 2
    else
      self.command.speed = 3
    end
  end

  def my_name
    self.class.const_get("NAME")
  end

  def acquire_target!
    if @target = self.sensors.radar.sort_by(&:distance).reject{|t| t.name == my_name}.first
      # lock radar and turret on target
      self.command.radar_heading = @target.heading
      #self.command.turret_heading = @target.heading
    else
      # naively spit left
      @target_last_position = nil
      @expected_location = nil
      self.command.radar_heading = self.sensors.radar_heading - RTanque::Heading::EIGHTH_ANGLE
      self.command.turret_heading = self.command.radar_heading
    end
  end

  def determine_target_vectors!
    return unless @target

    target_position = calculate_position(self.sensors.position, @target.heading, @target.distance)
    if @target_last_position
      target_movement_vector = @target_last_position.heading(target_position)
      target_speed = @target_last_position.distance(target_position)

      # figure out where the target will be next tick, and where we will be next tick
      ticks_until_bullet_hits = @target.distance / fire_power(@target.distance) / 2
      target_expected_location = calculate_position(target_position, target_movement_vector, target_speed * ticks_until_bullet_hits)
      my_expected_location = calculate_position(self.sensors.position, self.sensors.heading, self.sensors.speed)
      self.command.turret_heading = my_expected_location.heading(target_expected_location)
    end
    @target_last_position = target_position
  end

  def fire_power(distance)
    if distance < 250
      5
    else
      10
    end
  end

  def fire_when_ready!
    if @target
      if (self.sensors.radar_heading.to_degrees - @target.heading.to_degrees).abs < 2
        # control your firepower
        self.command.fire(fire_power(@target.distance))
      end
    end
  end

  def calculate_position(start_position, heading, distance)
    RTanque::Point.new(
      start_position.x + Math.sin(heading) * distance,
      start_position.y + Math.cos(heading) * distance,
      self.arena
    )
  end

  # protect from hacking
  class << self
    def send(*args, &block)
      puts "#{caller[0].split(":").first} is trying to hack me!!!!"
    end
  end
end
