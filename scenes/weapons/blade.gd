extends CharacterBody3D

var default_height = 1
var direction = Vector3.ZERO
var start_position = Vector3.ZERO

var weapon_properties
# This is the weapon slot this weapon is assigned to on the wielder
var weapon_slot = 0
var activated = false
var wielder
var scale_extended = 2
var scale_retracted = 0
var scale_increment = Vector3( 0.2, 0.2, 0.2 )
var collision_radius_min = 1.1
var collision_radius_max = 2.1
var collision_radius_inc = 0.2

func initialize( spawn_position, look_direction, wielder_node, properties ) :
	wielder = wielder_node
	weapon_properties = properties
	
	var group_fmt = "player%sweapon"
	if not wielder.is_player :
		group_fmt = "enemy%sweapon"
	var group_name = group_fmt % wielder.character_num
	
	position = wielder.global_position - Vector3( 0.0, 0.4, 0.0 )
	
	add_collision_exception_with ( wielder )
	add_to_group( "shots" )
	add_to_group( group_name )
	activate( )
	
func _process( delta ) :
	if activated and $weapon_blade.scale.x < scale_extended :
		print( "Blade Position : ", position, " Collision Radius : ", $blade_collision.shape.radius )
		$weapon_blade.scale += scale_increment
		if $weapon_blade.scale.x > scale_extended :
			$weapon_blade.scale = Vector3( scale_extended, scale_extended, scale_extended )
			
		$blade_collision.shape.radius += collision_radius_inc
		if $blade_collision.shape.radius > collision_radius_max :
			$blade_collision.shape.radius = collision_radius_max
		
	if not activated :
		# We're retracting 
		$weapon_blade.scale -= scale_increment
		$blade_collision.shape.radius -= collision_radius_inc
		if $weapon_blade.scale.x <= scale_retracted :
			queue_free( )

func _physics_process( delta ) :
	position = wielder.global_position - Vector3( 0.0, 0.4, 0.0 )
	velocity = Vector3.ZERO * delta
	rotate_y( weapon_properties.speed * delta * -1 )
	
	var hit = move_and_collide( velocity )

	if hit != null :
		var collision = hit.get_collider( )
		if collision != null :
			if collision.is_in_group( "enemies" ) or collision.is_in_group( "players" ) or collision.is_in_group( "resource_source" ) :
				if collision.has_method( "hit" ) :
					collision.hit( weapon_properties.damage, position, wielder )
						#
			#if not collision.is_in_group( "shots" ) :
				#queue_free( )

func activate( ) :
	activated = true

func deactivate( ) :
	activated = false

