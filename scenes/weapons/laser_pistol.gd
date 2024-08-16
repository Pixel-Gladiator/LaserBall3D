extends CharacterBody3D

var default_height = 1
var shot_direction = Vector3.ZERO
var start_position = Vector3.ZERO

var weapon_properties

var wielder
var in_progress = false

func initialize( spawn_position, look_direction, wielder_node, properties ) :
	wielder = wielder_node
	weapon_properties = properties
	start_position = spawn_position
	position = start_position
	var height_diff = position.y + wielder.position.y
	position.y = height_diff
	var look_pos = wielder.position
	look_pos.y = position.y
	
	#transform = wielder.transform
	
	if not wielder.is_player( ) :
		rotate_y( 1.5 )

	#look_at_from_position( look_pos, position )
	
	shot_direction = look_direction
	velocity = shot_direction * weapon_properties.speed
	
	add_collision_exception_with( self )
	add_collision_exception_with( wielder )
	add_to_group( "shots" )
	
func _physics_process( delta ) :
	velocity = shot_direction * weapon_properties.speed * delta
	#velocity.x = shot_direction.x * weapon_properties.speed * delta
	#velocity.y = 0
	#velocity.z = shot_direction.z * weapon_properties.speed * delta
	
	var collision = move_and_collide( velocity )

	if collision != null and not in_progress :
		in_progress = true
		var victim = collision.get_collider( )
		if victim != null :
			if ( wielder.is_player( ) and victim.is_in_group( "enemies" ) ) or victim.is_in_group( "resource_source" ) or ( not wielder.is_player( ) and victim.is_in_group( "players" ) ) :
				if victim.has_method( "hit" ) :
					victim.hit( weapon_properties.damage, position, wielder )
						
			if not victim.is_in_group( "shots" ) :
				queue_free( )
			
	elif position.distance_to( start_position ) > weapon_properties.range :
		queue_free( )
		
