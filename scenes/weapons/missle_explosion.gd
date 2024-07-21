extends Node3D

func _ready( ) :
	$CPUParticles3D.emitting = true

func initialize( missile_position ) :
	position = missile_position
