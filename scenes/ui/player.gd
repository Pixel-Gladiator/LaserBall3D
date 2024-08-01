extends SubViewport

@onready var node_viewport: SubViewport = $SubViewport

var health_radius_max = 0.475
var health_height_max = 0.95
var energy_inner_radius = 0.52
var energy_outer_radius_max = 0.78
var exp_inner_radius_max = 0.82
var exp_outer_radius_max = 0.98

# Values passed in should be a deciaml percentage betweem 0.0 and 1.0
func set_health( health : float ) :
	$health_outer/health.mesh.radius = health * health_radius_max
	$health_outer/health.mesh.height = health * health_height_max

func set_energy( energy : float ) :
	$energy_outer/energy.mesh.outer_radius = energy * energy_outer_radius_max

func set_experience( experience : float ) :
	$experience_outer/experience.mesh.outer_radius = experience * exp_outer_radius_max
