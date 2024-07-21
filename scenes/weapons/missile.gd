extends CharacterBody3D

@export var missile_explosion_scene: PackedScene

var default_height = 1
var direction = Vector3.ZERO
var start_position = Vector3.ZERO

var weapon_properties
var damage
var exploding = false
var player
var explosion

func initialize( spawn_position, look_direction, player_node, properties ) :
	player = player_node
	weapon_properties = properties
	damage = weapon_properties.damage
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

func _process( delta ) :
	if exploding :
		$MissleHit.shape.radius *= 1.5
		damage -= 1
		#if explosion.tree_exited :
		queue_free( )

func _physics_process( delta ) :
	velocity = direction * weapon_properties.speed * delta
	if exploding :
		velocity = direction * delta
	
	var hit = move_and_collide( velocity )

	if hit != null :
		var collision = hit.get_collider( )
		if collision != null :
			if collision.is_in_group( "enemies" ) or collision.is_in_group( "resource_source" ) :
				if collision.has_method( "hit" ) :
					collision.hit( damage, position, player )
					explode( )
						
			if not collision.is_in_group( "shots" ) :
				exploding = true

func explode( ) :
	print( "boom" )
	explosion = missile_explosion_scene.instantiate( )
	explosion.initialize( position )
	get_parent( ).add_child( explosion )

