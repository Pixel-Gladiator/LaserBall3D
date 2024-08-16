extends Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func initialize( colour ) :
	#position = hit_position
	var material = $CPUParticles3D.mesh.surface_get_material( 0 )
	if material :
		material.albedo_color = colour
		#print( "position : ", hit_position, " colour : ", colour )
	$CPUParticles3D.emitting = true
