extends Node

# Player scene
@export var player_scene: PackedScene
# Enemy scenes
@export var enemy_scene: PackedScene
# resource  Scenes
@export var resource_scene: PackedScene
@export var max_resources = 250
# This is the percentage chance of spawning a resource  expressed as a decimal between 0 and 1
@export var resource_chance = max_resources / ( max_resources * 2 )

# Keep track of all the enemies
@export var enemy_count = 0
# Set maximum counts for each type of enemy
@export var enemy_max = 4
# Track the total number of enemies
@export var enemy_count_total = 0

var player_count = 0
var player_highest_level = 0

var time_start = Time.get_ticks_msec( )
var time_interval = time_start

@onready var game_area = get_node( "NavigationRegion3D/GameArea" )
		
# Called when the node enters the scene tree for the first time.
func _ready( ) :
	# Create the randomized Game Area
	for b in max_resources :
		#continue
		create_resource( b, true )
	
	# Add the player
	add_player( )
	
	$EnemySpawnTimer.wait_time = 0.5

func _process( _delta ) :
	time_interval = Time.get_ticks_msec( ) - time_start

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process( _delta ) :
	get_tree( ).call_group( "enemies", "update_target_location",  )

func add_player( ) :
	var new_player = player_scene.instantiate( )
	var spawn_point_a = get_node( "NavigationRegion3D/GameArea/PlayerSpawnPointA" )
	new_player.initialize( spawn_point_a )
	add_child( new_player )
	var players = get_tree( ).get_nodes_in_group( "players" )
	for player in players :
		if player.level > player_highest_level :
			player_highest_level = player.level
	player_count += 1
	#enemy_max = player_highest_level * 5

func create_resource( resource_num, game_start ) :
	# Create a new instance of the resource  scene.
	# We may want to add something here for different resource types
	# like some sort of glass/crystal that cannot be destroyed by laser
	# weapons, instead it refracts the laser as it passes through and
	# shoot things on the other side.
	if get_tree( ) != null :
		var resouces = get_tree( ).get_nodes_in_group( "resource_source" )
		resource_chance = 1 - ( resouces.size( ) / max_resources )
		
	if randf( ) < resource_chance :
		var resource  = resource_scene.instantiate( )
		# Choose a random location on the SpawnPath.
		# We store the reference to the SpawnLocation node.
		var resource_spawn_location = get_node( "NavigationRegion3D/GameArea/ResourceSpawnPath/ResourceSpawnLocation" )
		# And give it a random offset.
		resource_spawn_location.progress = resource_num * 10
		
		resource.initialize( resource_spawn_location, game_start )
		# Spawn the mob by adding it to the Main scene.
		game_area.add_child( resource )

func dec_enemy_count( ) :
	if enemy_count > 0 :
		enemy_count -= 1
	else :
		enemy_count = 0
	

func inc_enemy_count( ) :
	enemy_count += 1
	enemy_count_total += 1

func create_enemy( ) :
	inc_enemy_count( )
	# Create a new instance of the Mob scene.
	var mob = enemy_scene.instantiate( )
	# Choose a random location on the SpawnPath.
	# We store the reference to the SpawnLocation node.
	var mob_spawn_location = get_node( "NavigationRegion3D/GameArea/EnemySpawnPath/EnemySpawnLocation" )
	# And give it a random offset.
	mob_spawn_location.progress_ratio = randf( )
	mob_spawn_location.position.y += 0.1
	mob.initialize( mob_spawn_location.position, enemy_count_total )
	# Spawn the mob by adding it to the Main scene.
	game_area.add_child( mob )

func _on_enemy_spawn_timer_timeout( ) :
	if enemy_count < enemy_max :
		print( "Enemies are at ", enemy_count, " of ", enemy_max )
		create_enemy( )

func _on_environment_renewal_timer_timeout( ) :
	create_resource( randf( ) * max_resources, false )
