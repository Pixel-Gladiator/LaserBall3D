extends CharacterBody3D

var default_height = 1
var direction = Vector3.ZERO
var start_position = Vector3.ZERO

var weapon_properties

var player

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
			

