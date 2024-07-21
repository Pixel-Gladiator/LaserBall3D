extends CharacterBody3D

var default_height = 1
var direction = Vector3.ZERO
var start_position = Vector3.ZERO

var weapon_properties

var shooter
var in_progress = false

func initialize( spawn_position, look_direction, shooter_node, properties ) :
	shooter = shooter_node
	weapon_properties = properties
	
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
			

