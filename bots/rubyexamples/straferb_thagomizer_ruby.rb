# from http://www.rubyexample.com/snippet/ruby/straferb_thagomizer_ruby

class Strafe < RTanque::Bot::Brain
  NAME = 'Strafe Master'
  include RTanque::Bot::BrainHelper
 
  TICKS_BETWEEN_SWEEPS = 500
  RUN_AWAY_TICKS = 1200
 
  def initialize(arena)
    super
    @run_away_dest = nil
    @target = nil
    @health = 100
    @run_away = 0
    @being_attacked = false
  end
 
  def tick!
    update_health
    update_heading if sensors.speed != 0
 
    if @run_away > 0
      @run_away -= 1
      command.speed = MAX_BOT_SPEED
    end
 
    radar_sweep if @sweep_start_heading
 
    engage_target
 
    if @target and @target.heading.delta(sensors.turret_heading).abs < RTanque::Heading::ONE_DEGREE * 2.0
      command.fire(MAX_FIRE_POWER * 0.75)
    end
 
    # If my last radar sweep was more than x ticks ago, sweep
    if (sensors.ticks % TICKS_BETWEEN_SWEEPS == 1)
      radar_sweep(true)
    end
 
    if @being_attacked
      run_away
    end
  end
 
  def update_heading
    if @run_away <= 0
      command.speed = 0
      return
    end
 
    position = sensors.position
 
    if position.within_radius?(@run_away_point, 10)
      pick_run_away_point
      return
    end
 
    if (position.on_wall? or position.outside_arena?)
      pick_run_away_point
      return
    end
 
    command.heading = sensors.position.heading(@run_away_point)
  end
 
  def pick_run_away_point
    @run_away_point = RTanque::Point.rand(self.arena)
    command.heading = sensors.position.heading(@run_away_point)
  end
 
  def run_away
    @run_away = RUN_AWAY_TICKS
 
    command.speed = MAX_BOT_SPEED
    pick_run_away_point
  end
 
  def update_health
    @being_attacked = @health > sensors.health
    @health = sensors.health
  end
 
  def pick_target
    closest_target = closest_bot
 
    return closest_target unless @target
 
    # locate current target
    @target = sensors.radar.find { |reflection| reflection.name == @target.name }
    return @target unless closest_bot
    return closest_target unless @target
 
    if closest_bot.distance < @target.distance
      return closest_bot
    else
      return @target
    end
  end
 
  def engage_target
    @target = pick_target
 
    if @target
      command.turret_heading = @target.heading
      command.radar_heading = @target.heading
    else
      radar_sweep(:start) unless @sweep_start_heading
    end
  end
 
  def closest_bot
    sensors.radar.min_by { |reflection| reflection.distance }
  end
 
  def radar_sweep(start_sweep = false)
    @sweep_start_heading = sensors.radar_heading if start_sweep
    return unless @sweep_start_heading
 
    command.radar_heading = sensors.radar_heading + MAX_RADAR_ROTATION
 
    unless start_sweep
      if sensors.radar_heading.delta(@sweep_start_heading).abs < MAX_RADAR_ROTATION/2
        @sweep_start_heading = nil
        return
      end
    end
  end
end