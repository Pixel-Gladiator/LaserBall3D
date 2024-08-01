extends CharacterBody3D

var default_height = 1
var direction = Vector3.ZERO
var start_position = Vector3.ZERO

var weapon_properties

var part_angle = 0
var part_radius = 0.5
var angle_inc = 18

var shooter
var in_progress = false

func initialize( spawn_position, look_direction, shooter_node, properties ) :
	shooter = shooter_node
	weapon_properties = properties
	start_position = spawn_position
	position = spawn_position
	var height_diff = spawn_position.y - shooter.position.y
	look_at_from_position( Vector3( shooter.position.x, shooter.position.y + height_diff, shooter.position.z ), position )
	#print( "start pos : ", position )
	#print( "look pos : ", look_position )
	if not shooter.is_player( ) :
		rotate_y( 1.5 )
	
	direction = look_direction
	
	velocity = direction * weapon_properties.speed
	
	add_collision_exception_with( self )
	add_collision_exception_with( shooter )
	add_to_group( "shots" )

func _physics_process( delta ) :
	part_angle += angle_inc
	if part_angle > 360 :
		part_angle = part_angle - 360
	$RailShot/CPUParticles3D.position.x = part_radius * sin( deg_to_rad( part_angle ) )
	$RailShot/CPUParticles3D.position.z = part_radius * cos( deg_to_rad( part_angle ) )
	$RailShot/CPUParticles3D2.position.x = part_radius * sin( deg_to_rad( part_angle + 120 ) )
	$RailShot/CPUParticles3D2.position.z = part_radius * cos( deg_to_rad( part_angle + 120 ) )
	$RailShot/CPUParticles3D3.position.x = part_radius * sin( deg_to_rad( part_angle + 240 ) )
	$RailShot/CPUParticles3D3.position.z = part_radius * cos( deg_to_rad( part_angle + 240 ) )
	
	velocity = direction * weapon_properties.speed * delta
	
	var collision = move_and_collide( velocity )

	if collision != null and not in_progress :
		in_progress = true
		var victim = collision.get_collider( )
		if victim != null :
			if ( shooter.is_player( ) and victim.is_in_group( "enemies" ) ) or victim.is_in_group( "resource_source" ) or ( not shooter.is_player( ) and victim.is_in_group( "players" ) ) :
				if victim.has_method( "hit" ) :
					victim.hit( weapon_properties.damage, position, shooter )
						
			if not victim.is_in_group( "shots" ) :
				queue_free( )
			
	elif position.distance_to( start_position ) > weapon_properties.range :
		queue_free( )
		
