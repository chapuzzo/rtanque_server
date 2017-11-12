# from https://gist.github.com/trishume/8b8f1c91d49646472612

# Modified Seek&Destroy example that hugs the left side
# Includes commented out experiments in strats
class SeekAndDestroy < RTanque::Bot::Brain
include RTanque::Bot::BrainHelper

def tick!
    @desired_heading ||= nil
    @rands ||= (1..10).map { rand() * Math::PI * 2 }
    @dirn ||= RTanque::Bot::BrainHelper::MAX_BOT_SPEED

    if sensors.position.x <= 200
      if sensors.heading == RTanque::Heading::NORTH
        if sensors.position.y >= 400
          @dirn = -RTanque::Bot::BrainHelper::MAX_BOT_SPEED
        elsif sensors.position.y <= 200
          @dirn = RTanque::Bot::BrainHelper::MAX_BOT_SPEED
        end
      else
        @dirn = 0
      end
      command.heading = RTanque::Heading::NORTH
    else
      command.heading = RTanque::Heading::WEST
    end
    command.speed = @dirn

    if (lock = self.get_radar_lock)
        self.destroy_lock(lock)
        @desired_heading = nil
      else
        self.seek_lock
    end
end

def destroy_lock(reflection)
    if sensors.position.on_wall?
      # command.heading = sensors.heading + RTanque::Heading::ONE_DEGREE*5
    else
      # command.heading = @rands[self.sensors.ticks/60 % 10]
    end

    delta = (reflection.heading.delta(sensors.radar_heading)).abs

    command.radar_heading = reflection.heading
    # factor = [-5,0,5][self.sensors.ticks/10 % 3]
    # factor *= 0.2 if reflection.distance > 200
    # factor = 0 if delta > RTanque::Heading::ONE_DEGREE * 15.0
    # factor = Math.sin(self.sensors.ticks/20) * 5.0
    factor = 0
    command.turret_heading = reflection.heading + RTanque::Heading::ONE_DEGREE * factor
    # command.speed = reflection.distance > 200 ? RTanque::Bot::BrainHelper::MAX_BOT_SPEED : RTanque::Bot::BrainHelper::MAX_BOT_SPEED / 2.0
    if delta < RTanque::Heading::ONE_DEGREE * 8.0
        command.fire(reflection.distance < 200 ? RTanque::Bot::BrainHelper::MIN_FIRE_POWER : RTanque::Bot::BrainHelper::MAX_FIRE_POWER)
    end
end

def seek_lock
    if sensors.position.on_wall?
        @desired_heading = sensors.heading + RTanque::Heading::HALF_ANGLE
    end
    command.radar_heading = sensors.radar_heading + RTanque::Bot::BrainHelper::MAX_RADAR_ROTATION
    command.turret_heading = command.radar_heading
    command.speed = 1
    if @desired_heading
        # command.heading = @desired_heading
        command.turret_heading = @desired_heading
    end
end

def get_radar_lock
    @locked_on ||= nil
    lock = if @locked_on
        sensors.radar.find { |reflection| reflection.enemy_name == @locked_on } || sensors.radar.first
    else
        sensors.radar.first
    end
    @locked_on = lock.enemy_name if lock
    lock
end
end
