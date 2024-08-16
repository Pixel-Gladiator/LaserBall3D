extends CharacterBody3D

var default_height = 0.25
var default_inner_radius = 1.0
var default_radius = 1.25
var direction = Vector3.ZERO
var start_position = Vector3.ZERO

var weapon_properties

var player

func initialize( spawn_position, _look_direction, player_node, properties ) :
	player = player_node
	weapon_properties = properties
	
	position = spawn_position
	position.y += 0.4
	#look_at_from_position( spawn_position, position )
	#print( "start pos : ", position )
	#print( "look pos : ", look_position )
	
	#direction = look_direction
	
	#velocity = direction * weapon_properties.speed
	velocity = Vector3.ZERO
	$JoltRing.mesh.inner_radius = default_inner_radius
	$JoltRing.mesh.outer_radius = default_radius
	$JoltHit.shape.radius = default_radius
	add_collision_exception_with( self )
	add_collision_exception_with( player_node )
	add_to_group( "shots" )
	
func _physics_process( delta ) :
	position = player.global_position
	#velocity = direction * weapon_properties.speed * delta
	var radius_growth = weapon_properties.speed * delta
	$JoltRing.mesh.outer_radius += radius_growth
	$JoltRing.mesh.inner_radius += radius_growth
	$JoltHit.shape.radius += radius_growth
	print( "Radius : ", $JoltHit.shape.radius, " of range ", weapon_properties.range )
	
	var hit = move_and_collide( velocity )

	if hit != null :
		var collision = hit.get_collider( )
		if collision != null :
			if collision.is_in_group( "enemies" ) or collision.is_in_group( "resource_source" ) :
				if collision.has_method( "hit" ) :
					collision.hit( weapon_properties.damage, position, player )
	
	if $JoltHit.shape.radius > weapon_properties.range :
		queue_free( )
