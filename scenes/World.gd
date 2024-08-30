extends Node

# Player scene
@export var player_scene: PackedScene
# UI
@export var player_ui: PackedScene
var ui
# Enemy scenes
@export var enemy_scene: PackedScene
# resource  Scenes
@export var resource_scene: PackedScene
@export var resource_hit_scene: PackedScene
@export var energy_scene: PackedScene

var max_resources = 350
# This is the percentage chance of spawning a resource expressed as a decimal between 0 and 1
var resource_chance = float( max_resources ) / ( float( max_resources ) * 2 )
var resource_spacing = 1

# Keep track of all the enemies
var enemy_count = 0
# Set maximum enemy count
var enemy_max = 1
var enemy_max_multiplier = 2
# Track the total number of enemies
var enemy_count_total = 0

var enemy_energy_pool = 0

var player_count = 0
var player_highest_level = 1

var time_start = Time.get_ticks_msec( )
var time_interval = time_start

@onready var game_area = get_node( "NavigationRegion3D/GameArea" )

# Called when the node enters the scene tree for the first time.
func _ready( ) :
	# Create the randomized Game Area
	var resource_spawn_location = get_node( "NavigationRegion3D/GameArea/ResourceSpawnPath/ResourceSpawnLocation" )
	# Set the maximum points on the SpawnPath.
	resource_spawn_location.progress_ratio = 1
	max_resources = int( resource_spawn_location.progress )
	resource_spawn_location.progress_ratio = 0
	for b in max_resources :
		create_resource( float( b ), true )
	
	# Add the player
	add_player( )
	
	$EnemySpawnTimer.wait_time = 0.5

func _process( _delta ) :
	time_interval = Time.get_ticks_msec( ) - time_start

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process( _delta ) :
	get_tree( ).call_group( "enemies", "update_target_location",  )

var spawn_points = [
	"NavigationRegion3D/GameArea/PlayerSpawnPointA",
	"NavigationRegion3D/GameArea/PlayerSpawnPointB",
	"NavigationRegion3D/GameArea/PlayerSpawnPointC",
	"NavigationRegion3D/GameArea/PlayerSpawnPointD"
]
var player_ui_positions = [
	"Control/UI_Position_A",
	"Control/UI_Position_B",
	"Control/UI_Position_C",
	"Control/UI_Position_D"
]
func add_player( ) :
	#ui = player_ui.instantiate( )
	#ui.initialize( health, energy, experience )
	# using player_count here will be a problem, but works for now since we don't have multiplayer anyway
	#get_node( player_ui_positions[ player_count ] ).add_child( ui )
	
	var new_player = player_scene.instantiate( )
	var spawn_point = get_node( spawn_points[ ( randi( ) % 4 ) ] )
	new_player.initialize( spawn_point )
	new_player.death.connect( self.player_death )
	game_area.add_child( new_player )
	player_count += 1

func create_resource( resource_num, game_start ) :
	# Create a new instance of the resource scene.
	# We may want to add something here for different resource types
	# like some sort of glass/crystal that cannot be destroyed by laser
	# weapons, instead it refracts the laser as it passes through and
	# shoot things on the other side.
	if get_tree( ) != null :
		var resouces = get_tree( ).get_nodes_in_group( "resource_source" )
		if game_start :
			resource_chance = 0.1
		else :
			resource_chance = 1.0 - ( float( resouces.size( ) ) / float( max_resources ) )
	else :
		print( "No tree to find resouces" )
	
	if randf( ) < resource_chance :
		print( "Generating resource ", resource_num )
		var resource  = resource_scene.instantiate( )
		# We store the reference to the SpawnLocation node.
		var resource_spawn_location = get_node( "NavigationRegion3D/GameArea/ResourceSpawnPath/ResourceSpawnLocation" )
		# Choose a random location on the SpawnPath.
		resource_spawn_location.progress_ratio = ( float( resource_num ) / float( max_resources ) )
		resource.initialize( resource_spawn_location.position, game_start, resource_num )
		resource.resource_damage.connect( resource_damage )
		resource.resource_death.connect( resource_death )
		# Spawn the mob by adding it to the Main scene.
		game_area.add_child( resource )
		check_position( resource, resource_num )

func check_position( new_resource, resource_num ) :
	# Don't allow spawning inside another resouce
	if get_tree( ) != null :
		var resources = get_tree( ).get_nodes_in_group( "resource_source" )
		var r = 0
		for resource in resources :
			if r != resource_num :
				var resource_pos = new_resource.position.distance_to( resource.position )
				if resource_pos < resource_spacing :
					#position = resource.position - position
					#print( "Resource ", resource_number, " too close (", resource_pos, ") to resource ", r, " (", resource_spacing, ")" )
					new_resource.position.x = new_resource.position.x + randf_range( resource_spacing * -1, resource_spacing )
					new_resource.position.z = new_resource.position.z + randf_range( resource_spacing * -1, resource_spacing )
					#print( "Resource ", resource_number, " : new position : ", position )
					#check_position(  )
			r += 1
	else :
		print( "There is no tree of resources?" )

func resource_damage( resource, colour ) :
	var impact = resource_hit_scene.instantiate( )
	impact.initialize( colour )
	resource.add_child( impact )

func resource_death( resource_position, resource_energy, resource_hitter ) :
	var energy_blob = energy_scene.instantiate( )
	energy_blob.initialize( resource_energy, resource_position, resource_hitter )
	game_area.add_child( energy_blob )

func dec_enemy_count( ) :
	if enemy_count > 0 :
		enemy_count -= 1
	else :
		enemy_count = 0

func inc_enemy_count( ) :
	enemy_count += 1
	enemy_count_total += 1

func create_enemy( ) :
	if false :
		inc_enemy_count( )
		# Create a new instance of the Mob scene.
		var new_enemy = enemy_scene.instantiate( )
		# Choose a random location on the SpawnPath.
		# We store the reference to the SpawnLocation node.
		var enemy_spawn_location = get_node( "NavigationRegion3D/GameArea/EnemySpawnPath/EnemySpawnLocation" )
		# And give it a random offset.
		enemy_spawn_location.progress_ratio = randf( )
		enemy_spawn_location.position.y += 0.1
		new_enemy.initialize( enemy_spawn_location.position, enemy_count_total )
		new_enemy.add_to_enemy_energy_pool.connect( self.add_to_enemy_energy_pool )
		new_enemy.death.connect( self.dec_enemy_count )
		new_enemy.add_experience_to_player.connect( self.add_experience_to_player )
		if enemy_energy_pool > 300 :
			new_enemy.collect_energy( 300 )
			enemy_energy_pool -= 300
		# Spawn the new enemy by adding it to the Main scene.
		game_area.add_child( new_enemy )

func add_experience_to_player( player_num : int, experience : float ) :
	var players = get_tree( ).get_nodes_in_group( "players" )
	for player in players :
		if player.get_num( ) == player_num :
			player.add_experience( experience )
	

func set_highest_player_level( ) :
	var players = get_tree( ).get_nodes_in_group( "players" )
	for player in players :
		if player.level > player_highest_level :
			player_highest_level = player.level

func add_to_enemy_energy_pool( energy_amount : float ): 
	enemy_energy_pool += energy_amount
	print(  "Energy Pool : ", enemy_energy_pool )

func player_death( player_num ) :
	print( "Player ", player_num, " has died" )
	# When we have a UI, we need to bring up something here

func _on_enemy_spawn_timer_timeout( ) :
	enemy_max = player_highest_level * enemy_max_multiplier
	if enemy_count < enemy_max :
		create_enemy( )
		#print( "Enemies are at ", enemy_count, " of ", enemy_max )
	else :
		# If we can't spawn new enemies, check if we can level them up.
		var enemies = get_tree( ).get_nodes_in_group( "enemies" )
		for enemy in enemies :
			if randf( ) > 0.5 and enemy_energy_pool > 300 :
				enemy.collect_energy( 300 )
				enemy_energy_pool -= 300

func _on_environment_renewal_timer_timeout( ) :
	create_resource( int( randf( ) * max_resources ), false )
