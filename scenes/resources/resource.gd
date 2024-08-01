extends CharacterBody3D

@export var resource_hit_scene: PackedScene
@export var energy_scene: PackedScene

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

var energy_blob

# Functions
###############################################################################
func initialize( spawn_point, game_start ) :
	# Don't allow spawning inside another resouce
	if get_tree( ) != null :
		var resources = get_tree( ).get_nodes_in_group( "resource_source" )
		for resource in resources :
			var resouce_pos = position.distance_to( resource.position )
			if resouce_pos < min_radius :
				var y = spawn_point.position.y
				position = spawn_point.position * 1.5
				position.y = y
	else :
		position = spawn_point.position
	
	if game_start :
		target_health = 3 + randf( ) * ( max_health * 0.75 )
		health = target_health
	else :
		target_health = 3 + randf( ) * ( max_health * 0.75 )
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
	energy_blob = energy_scene.instantiate( )
	
func _process( _delta ) :
	if health <= target_health :
		regenerate( )
	
func hit( damage, hit_position, hitter ) :
	time_last_hit = Time.get_ticks_msec( )
	var impact = resource_hit_scene.instantiate( )
	health -= damage
	
	var material = $MeshInstance3D.mesh.surface_get_material( 0 )
	if material :
		impact.initialize( material.albedo_color, hit_position )
		#print( "health : ", health, " of ", max_health, " Colour : ", material.albedo_color )
	else :
		impact.initialize( Color.DARK_OLIVE_GREEN, hit_position )
	
	if health > 0 :
		translate_health_to_size( )
	
	add_child( impact )
	
	if health <= 0 :
		energy_blob.initialize( energy, position, hitter )
		#var game_area = get_node( "NavigationRegion3D/GameArea" )
		get_parent( ).add_child( energy_blob )
		queue_free( )

func regenerate( ) :
	var now = Time.get_ticks_msec( )
	if now - time_last_hit > 250 and now - time_last_regen > 250  :
		time_last_regen = now
		health += 0.1
		if health <= target_health :
			translate_health_to_size( )

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
