# from http://www.rubyexample.com/snippet/ruby/cugel_v9rb_radw2020_ruby

class Cugel < RTanque::Bot::Brain
  NAME = 'Cugel'
  include RTanque::Bot::BrainHelper
 
  attr_accessor  :enemy
 
  def initialize(enemy)
    @enemy = enemy
    @enemy_position_veryold = RTanque::Point.new(500,400)
    @enemy_position_old = RTanque::Point.new(500,400)
    @enemy_position_new = RTanque::Point.new(500,400)
    @enemy_speed_old = 3
    @enemy_speed_new = 3
    @shell_speed =  fuego * RTanque::Shell::SHELL_SPEED_FACTOR
  end
 
  def tick!
    otear
    velocidad
    movimiento
    radar_y_torreta
    apuntar_y_disparar if @enemy
  end
 
  def otear
    sensors.radar.sort_by(&:distance)
    @enemy = sensors.radar.first
  end
 
  def apuntar_y_disparar
 
    enemyX = sensors.position.x + Math.sin(enemy.heading) * (enemy.distance)
    enemyY = sensors.position.y + Math.cos(enemy.heading) * (enemy.distance)
 
    enemy_position = RTanque::Point.new(enemyX, enemyY)
    @enemy_position_very = @enemy_position_old
    @enemy_position_old = @enemy_position_new
    @enemy_position_new = enemy_position
 
    enemy_vector_x = (@enemy_position_new.x - @enemy_position_old.x)
    enemy_vector_y = (@enemy_position_new.y - @enemy_position_old.y)
 
    enemy_speed = Math.sqrt(enemy_vector_x**2 + enemy_vector_y**2)
    @enemy_speed_old = @enemy_speed_new
    @enemy_speed_new = enemy_speed
    @enemy_acceleration = @enemy_speed_new - @enemy_speed_old
 
    ############### NEWTON STYLE ITERATIONS #######################
    t = (enemy.distance - 28) / @shell_speed
    for i in 1..6 do
      ptx = enemyX + enemy_vector_x * t + 0.5 * @enemy_acceleration * t**2
      pty = enemyY + enemy_vector_y * t + 0.5 * @enemy_acceleration * t**2
      t = (mi_posicion.distance(RTanque::Point.new(ptx , pty , @arena))-28) / @shell_speed
    end
    ############## END OF NEWTON STYLE ITERATIONS #################
 
    @enemy_point_prediction = RTanque::Point.new( ptx , pty , RTanque::Arena )
    angulo_objetivo = RTanque::Heading.new_between_points(mi_posicion, @enemy_point_prediction)
    command.turret_heading = angulo_objetivo
    clear_shot = ( sensors.turret_heading.radians.round(1) - angulo_objetivo.radians.round(1) ).abs == 0
    command.fire(fuego) if clear_shot
 
    command.radar_heading = enemy.heading
    otear
  end
 
  def offset
    time = (sensors.ticks) / 12
    (Math.sin( time )) > 0 ? 60 : -60
  end
 
  def movimiento
    #################### ESQUINAS #######################
    if (sensors.position.on_top_wall?) and (sensors.position.on_right_wall?)
      command.heading = RTanque::Heading.new_from_degrees(180 )
    elsif (sensors.position.on_bottom_wall?) and (sensors.position.on_right_wall?)
      command.heading = RTanque::Heading.new_from_degrees(270 )
    elsif (sensors.position.on_left_wall?) and (sensors.position.on_bottom_wall?)
      command.heading = RTanque::Heading.new_from_degrees(0 )
    elsif (sensors.position.on_left_wall?) and (sensors.position.on_top_wall?)
      command.heading = RTanque::Heading.new_from_degrees(90)
      #################### CUADRO EXTERIOR #######################
    elsif sensors.position.y > 600 and sensors.position.x < 1100
      command.heading = RTanque::Heading.new_from_degrees(90 + offset)
    elsif sensors.position.y > 100 and sensors.position.x > 1100
      command.heading = RTanque::Heading.new_from_degrees(180 + offset)
    elsif sensors.position.y < 100 and sensors.position.x > 100
      command.heading = RTanque::Heading.new_from_degrees(270 + offset)
    elsif sensors.position.y < 600 and sensors.position.x < 100
      command.heading = RTanque::Heading.new_from_degrees(0 + offset)
      #################### CUADRO INTERIOR #######################
    elsif sensors.position.y > 400 and sensors.position.x < 900
      command.heading = RTanque::Heading.new_from_degrees(0)
    elsif sensors.position.y > 300 and sensors.position.x > 900
      command.heading = RTanque::Heading.new_from_degrees(90)
    elsif sensors.position.y < 300 and sensors.position.x > 300
      command.heading = RTanque::Heading.new_from_degrees(180)
    elsif sensors.position.y < 400 and sensors.position.x < 300
      command.heading = RTanque::Heading.new_from_degrees(270)
    end
  end
 
  def fuego
    RTanque::Bot::MAX_FIRE_POWER
  end
 
  def radar_y_torreta
    command.radar_heading = sensors.radar_heading + MAX_RADAR_ROTATION
    command.turret_heading = sensors.radar_heading + MAX_TURRET_ROTATION
    otear
  end
 
  def mi_posicion
    RTanque::Point.new(sensors.position.x, sensors.position.y, RTanque::Arena)
  end
 
  def velocidad
    command.speed = RTanque::Bot::MAX_SPEED
  end
 
end

