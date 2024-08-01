extends Node3D

#func initialize( boost_position ) :
#	position = boost_position

func activate( ) :
	#var pivot = get_parent( )
	#position = get_parent( ).get_node( "Pivot/booster" ).position
	#var height_diff = position.y - pivot.global_position.y
	#look_at_from_position( Vector3( pivot.global_position.x, pivot.global_position.y + height_diff, pivot.global_position.z ), position )
	$CPUParticles3D.emitting = true

func deactivate( ) :
	$CPUParticles3D.emitting = false
