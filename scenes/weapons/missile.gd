extends CharacterBody3D

@export var missile_explosion_scene: PackedScene

var default_height = 1
var direction = Vector3.ZERO
var start_position = Vector3.ZERO

var weapon_properties
var damage
var exploding = false
var shooter
var explosion
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
	
func _process( delta ) :
	if exploding :
		$MissleHit.shape.radius *= 1.5
		#damage -= 1
		#if explosion.tree_exited :
		queue_free( )

func _physics_process( delta ) :
	velocity = direction * weapon_properties.speed * delta
	if exploding :
		velocity = direction * delta
		
	var collision = move_and_collide( velocity )

	if collision != null and not in_progress :
		in_progress = true
		var victim = collision.get_collider( )
		if victim != null :
			if ( shooter.is_player( ) and victim.is_in_group( "enemies" ) ) or victim.is_in_group( "resource_source" ) or ( not shooter.is_player( ) and victim.is_in_group( "players" ) ) :
				if victim.has_method( "hit" ) :
					victim.hit( weapon_properties.damage, position, shooter )
					explode( )
						
			if not victim.is_in_group( "shots" ) :
				exploding = true
			
	elif position.distance_to( start_position ) > weapon_properties.range :
		queue_free( )

func explode( ) :
	print( "boom" )
	explosion = missile_explosion_scene.instantiate( )
	explosion.initialize( position )
	get_parent( ).add_child( explosion )

