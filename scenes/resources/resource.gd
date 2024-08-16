extends CharacterBody3D

var resource_number = 0
var max_energy = 100.0
var energy = 1.0
var max_health = 10.0
var health = 1.0
var target_health = 1.0
var colour_increment = 0.01
var min_radius = 0.5
var min_height = 4.0
var time_last_hit = 0.0
var time_last_regen = 0.0
var newly_growing = false
var regenerate_increment = 0.1

signal resource_damage
signal resource_death

# Functions
###############################################################################
func initialize( spawn_position, game_start, resource_num ) :
	resource_number = resource_num
	
	position = spawn_position
	
	target_health = 3 + randf( ) * ( max_health * 0.75 )
	if game_start :
		health = target_health
	else :
		health = 0.1
		newly_growing = true
		
	var material = $MeshInstance3D.mesh.surface_get_material( 0 )
	if material :
		var rand_grey = 0.2 + ( randf( ) * 0.3 )
		var rand_red = randf( ) * 0.5 + 0.25
		var rand_green = randf( ) * 0.5 + 0.25
		material.albedo_color = Color( rand_red, rand_green, 0, 1 ).lerp( Color( rand_grey, rand_grey, rand_grey,1 ), 0.25 )
		energy = max_energy * ( 0.5 + rand_grey )
		colour_increment = ( 1 - material.albedo_color.r ) / max_health
	
	translate_health_to_size( )
	
	add_to_group( "resource_source" )

#func _ready( ) :
#	check_position( )

func _process( _delta ) :
	var now = Time.get_ticks_msec( )
	# Only regenerate every 250ms or 250ms after being hit
	if now - time_last_hit > 250 and now - time_last_regen > 250  :
		if health < target_health :
			regenerate( now )

func regenerate( now ) :
	time_last_regen = now
	health += regenerate_increment
	if health > target_health :
		health = target_health
	translate_health_to_size( )

func hit( damage, hit_position, hitter ) :
	time_last_hit = Time.get_ticks_msec( )
	health -= damage
	#print( "Resource ", resource_number, " health : ", health )
	var resource_colour = Color.DARK_OLIVE_GREEN
	var material = $MeshInstance3D.mesh.surface_get_material( 0 )
	if material :
		resource_colour = material.albedo_color
		
	if health > 0 :
		resource_damage.emit( self, resource_colour )
		translate_health_to_size( )
	
	else :
		resource_death.emit( position, energy, hitter )
		queue_free( )

func translate_health_to_size( ) :
	var minimum_height = min_height
	if newly_growing :
		minimum_height = health
		if minimum_height > min_height :
			newly_growing = false
	var health_pct = health / max_health
	var radius = min_radius + ( ( 2 * min_radius ) * ( health_pct ) )
	$MeshInstance3D.mesh.height = minimum_height + ( minimum_height * ( health_pct ) )
	$MeshInstance3D.mesh.radius = radius
	$CollisionShape3D.shape.radius = radius
	$NavigationObstacle3D.radius = radius * 1.25

func is_player( ) :
	return false
