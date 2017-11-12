# from http://www.rubyexample.com/snippet/ruby/honkeytank_bluesrb_patrickking_ruby

class GameOver < RTanque::Bot::Brain
  NAME = 'Honkeytank Blues'
  include RTanque::Bot::BrainHelper

  def setup
    @once = true
    @spinning = true


    if Random.rand > 0.5
      @direction = :counterclockwise
    else
      @direction = :clockwise
    end


    @nw_point = RTanque::Point.new 10, arena.height - 10
    @ne_point = RTanque::Point.new arena.width - 10, arena.height - 10
    @se_point = RTanque::Point.new arena.width - 10, 10
    @sw_point = RTanque::Point.new 10, 10

    @destination = @nw_point
  end


  def set_radar
    if @spinning
      command.radar_heading = sensors.radar_heading + RTanque::Heading::ONE_DEGREE * 5
    end

    if sensors.radar.any?
      @spinning = false
      command.turret_heading = sensors.radar.first.heading
    end


    if sensors.radar.count == 0
      @spinning = true
    end
  end


  def set_fire
    return unless sensors.radar.any?
    if (sensors.turret_heading.to_degrees - sensors.radar.first.heading.to_degrees).abs < 0.5 and sensors.gun_energy == 10 and sensors.radar.first.name != NAME
      command.fire 10
    end
  end

  def set_heading
    command.heading = RTanque::Heading.new_between_points(
    sensors.position,
    @destination
    )
    command.speed = MAX_BOT_SPEED


    if @direction == :clockwise
      case @destination
      when @nw_point
        if sensors.position.x <= @nw_point.x and sensors.position.y >= @nw_point.y
          @destination = @ne_point
        end
      when @ne_point
        if sensors.position.x >= @ne_point.x and sensors.position.y >= @ne_point.y
          @destination = @se_point
        end
      when @se_point
        if sensors.position.x >= @se_point.x and sensors.position.y <= @se_point.y
          @destination = @sw_point
        end
      when @sw_point
        if sensors.position.x <= @sw_point.x and sensors.position.y <= @se_point.y
          @destination = @nw_point
        end
      end
    elsif @direction == :counterclockwise
      case @destination
      when @nw_point
        if sensors.position.x <= @nw_point.x and sensors.position.y >= @nw_point.y
          @destination = @sw_point
        end
      when @ne_point
        if sensors.position.x >= @ne_point.x and sensors.position.y >= @ne_point.y
          @destination = @nw_point
        end
      when @se_point
        if sensors.position.x >= @se_point.x and sensors.position.y <= @se_point.y
          @destination = @ne_point
        end
      when @sw_point
        if sensors.position.x <= @sw_point.x and sensors.position.y <= @se_point.y
          @destination = @se_point
        end
      end
    end


  end


  def tick!
    @once ||= false;
    setup unless @once

    set_radar
    set_heading
    set_fire
  end
end
