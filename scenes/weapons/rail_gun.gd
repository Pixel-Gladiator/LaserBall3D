extends CharacterBody3D

var default_height = 1
var direction = Vector3.ZERO
var start_position = Vector3.ZERO

var weapon_properties

var player
var part_angle = 0
var part_radius = 0.5
var angle_inc = 18

func initialize( spawn_position, look_direction, player_node, properties ) :
	player = player_node
	weapon_properties = properties
	
	position = player.global_position
	position.y += 0.4
	look_at_from_position( spawn_position, position )
	#print( "start pos : ", position )
	#print( "look pos : ", look_position )
	
	direction = look_direction
	
	velocity = direction * weapon_properties.speed
	
	add_collision_exception_with( self )
	add_collision_exception_with( player_node )
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
	
	var hit = move_and_collide( velocity )

	if hit != null :
		var collision = hit.get_collider( )
		if collision != null :
			if collision.is_in_group( "enemies" ) or collision.is_in_group( "resource_source" ) :
				if collision.has_method( "hit" ) :
					collision.hit( weapon_properties.damage, position, player )
						
			if not collision.is_in_group( "shots" ) :
				queue_free( )
			

