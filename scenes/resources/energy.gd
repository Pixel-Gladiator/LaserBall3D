extends CharacterBody3D

const speed = 1.5
var half_speed = speed / 2.0
var energy_value = 0.0
var spin_speed = 0.75
var dec_x = true
var dec_z = true
var growing = false
var floating = Vector3( 0.0, 0.01, 0.0 )

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting( "physics/3d/default_gravity" )

func initialize( energy_amount, resource_position, hitter ) :
	var come_from = hitter.position
	velocity = come_from.direction_to( resource_position ) * ( energy_amount * 0.075 )
	position = resource_position
	# Ensure it appears above ground
	if position.y < 0 :
		position.y = 0.5
	position.y += 1 + randf( ) * 0.5
	
	energy_value = energy_amount
	velocity.y *= 1.1
	add_to_group( "energy_drop" )
	#print( "Energy V : ", velocity )

func _process( _delta ) :
	rotate_y( spin_speed * _delta )
	if growing :
		$MeshInstance3D.mesh.size += Vector3( 0.025, 0.025, 0.025 )
	else :
		$MeshInstance3D.mesh.size -= Vector3( 0.025, 0.025, 0.025 )
		
	if $MeshInstance3D.mesh.size.x <= 0.9 :
		growing = true
	elif $MeshInstance3D.mesh.size.x >= 1.1 :
		growing = false

func _physics_process( delta ) :
	# Add the gravity.
	if not is_on_floor( ) and position.y > 1.25 :
		velocity.y -= ( gravity ) * delta
		#print( "Energy Vel : ", velocity, " Pos : ", position )
	
	var collision = move_and_collide( velocity )
	if collision != null :
		var collector = collision.get_collider( )
		if collector != null :
			if collector.is_in_group( "enemies" ) or collector.is_in_group( "players" ) :
				collector.collect_energy( energy_value )
				queue_free( )
			elif collector.is_in_group( "resource_source" ) or collector.is_in_group( "ground" )  or collector.is_in_group( "energy_drop" ) :
				# We landed on a resource
				bounce( )

func bounce( ) :
	velocity.x = randf( ) * ( half_speed  / 2 )
	velocity.y = randf( ) * ( half_speed  / 4 )
	velocity.z = randf( ) * ( half_speed  / 2 )


