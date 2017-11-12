# from http://www.rubyexample.com/snippet/ruby/mikeblindbotrb_mikelovesrobots_ruby

class MikeBlindBot < RTanque::Bot::Brain
  NAME = 'MikeBlindBot'
  include RTanque::Bot::BrainHelper
 
  def tick!
    ## main logic goes here
    @direction_degrees ||= 0
    if self.sensors.position.on_top_wall?
      @direction_degrees = -180
    elsif self.sensors.position.on_bottom_wall?
      @direction_degrees = 0
    end
 
    @turret_degrees ||= 0
    @turret_degrees += 0.5
 
    self.command.speed = MAX_BOT_SPEED
    self.command.heading = RTanque::Heading.new_from_degrees(@direction_degrees)
    self.command.turret_heading = RTanque::Heading.new_from_degrees(@turret_degrees)
    self.command.fire MIN_FIRE_POWER
  end
end