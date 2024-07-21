extends Node3D

func initialize( boost_position ) :
	position = boost_position

func activate( ) :
	$CPUParticles3D.emitting = true
	
func deactivate( ) :
	$CPUParticles3D.emitting = false
