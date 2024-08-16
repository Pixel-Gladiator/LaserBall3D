extends CharacterBody3D

@onready var navigator = $NavigationAgent3D

# Weapons
@export var weapon_system: PackedScene
@export var blade: PackedScene
var weapon_list
var default_weapon = 0
var default_weapon_slot = 0
var weapon_slots = [
	{
		"enabled" : false,
		"equipped" : true,
		"weapon" : null,
		"weapon_system" : null,
		"level_unlocked" : 1,
		"weapons_available" : [ 1, 2, 3, 4 ],
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"weapon_system" : null,
		"level_unlocked" : 1,
		"weapons_available" : [ 0 ],
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"weapon_system" : null,
		"level_unlocked" : 1,
		"weapons_available" : [ 0 ],
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"weapon_system" : null,
		"level_unlocked" : 10,
		"weapons_available" : [ 5, 7 ],
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"weapon_system" : null,
		"level_unlocked" : 10,
		"weapons_available" : [ 5, 7 ],
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"weapon_system" : null,
		"level_unlocked" : 15,
		"weapons_available" : [ 6, 8, 9 ],
	},
]

# Enemy level
var level = 1
# Minimum speed of the mob in meters per second.
var base_speed = 6.0
# Experience points value
var base_experience = 10.0
@export var experience = base_experience
# Hit points
var default_health = 3.0
var max_health = default_health
var health = default_health
# The downward acceleration when in the air, in meters per second squared.
var fall_acceleration = 75.0

var default_colour = Color.WHITE

var default_detection_range = 25.0
@export var player_detection_range = default_detection_range
@export var resource_detection_range = default_detection_range
var energy_detection_range = 10.0
var default_target_desired_distance = 1.0
var target_desired_distance = default_target_desired_distance
var target_energy_desired_distance = 1.0
var attack_range = 3.0
var harvest_range = 1.0

var closest_target = null
var path_obstructed = false
var path_navigating_obstacle = false

var energy_collected = 0
var character_num = 0

var notified = 0
var notification_change = false

@onready var world = get_node( "/root/World" )

var last_postion = Vector3.ZERO
var not_moving = 0
var closest_target_last_position = Vector3.ZERO
var nothing_in_range = false
var nothing_in_range_count = 0
var nothing_in_range_count_max = 3

signal add_to_enemy_energy_pool
signal add_experience_to_player
signal death

# This function will be called from the Main scene.
func initialize( start_position, id ) :
	# We position the mob by placing it at start_position
	look_at_from_position( start_position, Vector3.ZERO, Vector3.UP )
	
	character_num = id
	
	# We calculate a forward velocity that represents the speed.
	velocity = Vector3.FORWARD * base_speed
	# We then rotate the velocity vector based on the mob's Y rotation
	# in order to move in the direction the mob is looking.
	velocity = velocity.rotated( Vector3.UP, rotation.y )
	
	add_to_group( "enemies" )
	adjust_colour( )
	enable_weapon_slots( )
	print( "Enemy ", character_num, " initialized" )

func _ready( ) :
	print( "Enemy ", character_num, " has joined the game" )

func get_num( ) :
	return character_num

func get_closest_player( ) :
	if get_tree( ).has_group( "players" ) :
		var players = get_tree( ).get_nodes_in_group( "players" )
		for player in players :
			var player_pos = position.distance_to( player.position )
			if player_pos < player_detection_range :
				if player != closest_target :
					#print( "Enemy : Player detected!" )
					closest_target = player
					#$NavigationAgent3D.target_desired_distance = target_desired_distance
		if notified != 1 and closest_target != null :
			#print( "Targeting Player" )
			notified = 1
			notification_change = true
		else :
			notification_change = false

func get_closest_energy( ) :
	var closest_energy = null
	if get_tree( ).has_group( "energy_drop" ) :
		var energy = get_tree( ).get_nodes_in_group( "energy_drop" )
		for engy in energy :
			var energy_pos = position.distance_to( engy.position )
			if energy_pos < energy_detection_range :
				if closest_energy == null or energy_pos < position.distance_to( closest_energy.position ) :
					closest_energy = engy
		
		if closest_energy != null :
			# If the enemy is chasing the player, but there is energy closer, choose the energy
			if closest_target == null or ( closest_target != null and position.distance_to( closest_target.position ) > position.distance_to( closest_energy.position ) ) :
				closest_target = closest_energy
				if notified != 3 and closest_target != null :
					#print( "Targeting Energy" )
					notified = 3
					notification_change = true
					
				else :
					notification_change = false
	return closest_energy

func get_closest_resource( ) :
	var resources = get_tree( ).get_nodes_in_group( "resource_source" )
	for resource in resources :
		var resouce_pos = position.distance_to( resource.position )
		if resouce_pos < resource_detection_range :
			resource_detection_range = resouce_pos
			closest_target = resource
	
	resource_detection_range = default_detection_range
	set_player_detection( default_detection_range )
	if notified != 2 and closest_target != null :
		#print( "Targeting Environment" )
		notified = 2
		notification_change = true
	else :
		notification_change = false

func set_closest_target( ) :
	var stuck = false
	if nothing_in_range :
		player_detection_range *= 1.5
		resource_detection_range *= 2
		energy_detection_range *= 3
		nothing_in_range_count += 1
		if nothing_in_range_count > nothing_in_range_count_max :
			# We can't find any resources or players, so 
			nothing_in_range_count = 0
			var boundaries = get_tree( ).get_nodes_in_group( "boundary" )
			var furthest_boundary = CharacterBody3D.new( )
			furthest_boundary.position = Vector3.ZERO
			for boundary in boundaries :
				if position.distance_to( boundary.position ) > position.distance_to( furthest_boundary.position ) :
					furthest_boundary = boundary
			closest_target = furthest_boundary
	else :
		player_detection_range = default_detection_range
		resource_detection_range = default_detection_range
		energy_detection_range = default_detection_range
	
	if closest_target != null :
		closest_target_last_position = closest_target.position
	# Find the closest player
	if not nothing_in_range :
		closest_target = null
		
	get_closest_player( )
	
	# If there is energy laying around near by, collect it
	var closest_energy = get_closest_energy( )
	
	if closest_target == null :
		get_closest_resource( )
	else :
		# When the player is detected, all nearby enemies are alerted
		var enemies = get_tree( ).get_nodes_in_group( "enemies" )
		for enemy in enemies :
			if enemy.get_num( ) != character_num and position.distance_to( enemy.position ) < default_detection_range :
				enemy.set_player_detection( default_detection_range * 1.5 )
	
	if closest_target != null :
		if closest_target.position.distance_to( closest_target_last_position ) < 0.05 :
			not_moving += 1
		else :
			not_moving = 0
		# If we're stuck on the environment, target it
		if not_moving > 120 :
			stuck = true
			get_closest_resource( )
		
		navigator.target_position = closest_target.position
		look_at( closest_target.position )
		if closest_energy == null or stuck :
			var slot_num = 0
			for weapon_slot in weapon_slots :
				if weapon_slot[ "enabled" ] and position.distance_to( closest_target.position ) <= weapon_slot[ "weapon_system" ].get_weapon_property( "range" ) :
					attack( weapon_slot, slot_num )
				else :
					if weapon_slot[ "weapon" ] != null and weapon_slot[ "weapon" ].has_method( "deactivate" ) :
						weapon_slot[ "weapon" ].deactivate( )
				slot_num += 1
	else :
		print( "Enemy : No targets within range" )
		nothing_in_range = true
	
	rotate_y( 1.5 )

func _process( _delta ) :
	# Find the closest player
	set_closest_target( )

func _physics_process( _delta ) :
	#if notification_change :
	#	print( "Global : ", global_transform.origin, " Position", position )
	var current_location = global_transform.origin
	#var current_location = position
	var next_location = navigator.get_next_path_position( )
	navigator.velocity = ( next_location - current_location ).normalized( ) * base_speed

func set_player_detection( new_value ) :
	player_detection_range = new_value

func adjust_colour( ) :
	var material = $Pivot/model/body.mesh.surface_get_material( 0 )
	if material :
		var adjust = 1 - ( health / max_health )
		if adjust > 0 :
			material.albedo_color = material.albedo_color.lerp( Color.DARK_RED, adjust )
		else :
			material.albedo_color = default_colour

func hit( damage, _hit_position, hitter ) :
	if hitter.is_player( ) :
		health -= damage
		if health <= 0 :
			print( "Enemy was destroyed.  Collecting ", experience, " XP" )
			#player.add_experience( experience )
			add_experience_to_player.emit( hitter.get_num( ), experience )
			print( "Player ", hitter.get_num( ), " now has ", hitter.get_experience( ), " XP" )
			death.emit( )
			#world.dec_enemy_count( )
			queue_free( )
		else :
			print( "Enemy hit : ", ( health / max_health ) * 100, "% health" )
			set_player_detection( position.distance_to( hitter.position ) )
			adjust_colour( )

func collect_energy( energy_amount ) :
	energy_collected += energy_amount
	add_to_enemy_energy_pool.emit( energy_amount * 0.25 )
	print( "Enemy ", character_num, " has ", energy_collected, " energy" )
	level_up( )

func expend_energy( energy_amount ) :
	energy_collected -= energy_amount
	print( "Enemy ", character_num, " has ", energy_collected, " energy" )

func level_up( ) :
	while energy_collected > 99.0 :
		energy_collected -= 100.0
		level += 1
		var new_max_health = default_health * ( level / 2.0 )
		if health == max_health :
			health = new_max_health
		else :
			# Gain health equal to the amount gained via the new maximum
			health += new_max_health - max_health
		max_health = new_max_health
		adjust_colour( )
		print( "Enemy ", character_num, " is level ", level )
		experience = base_experience * level
		enable_weapon_slots( )

func attack( weapon_slot, slot_num ) :
	if weapon_slot[ "enabled" ] :
		if not weapon_slot[ "weapon_system" ].get_weapon_property( "stays_active" ) or ( weapon_slot[ "weapon_system" ].get_weapon_property( "stays_active" ) and not weapon_slot[ "weapon_system" ].get_weapon_property( "active" ) ) :
			var slot_name = "Pivot/weapon_slot_%s" % slot_num
			var slot_path = NodePath( slot_name )
			var slot_node = get_node( slot_path )
		
			if ( weapon_slot[ "weapon_system" ].get_weapon_property( "stays_active" ) and not weapon_slot[ "weapon_system" ].get_weapon_property( "active" ) ) :
				# This is where we activate spinning the blade
				if weapon_slot[ "weapon" ].has_method( "activate" ) :
					print( "Activating Node!" )
					weapon_slot[ "weapon" ].activate( )
				else :
					print( "Nothing to activate" )
				
			weapon_slot[ "weapon_system" ].set_active( true, slot_num )
			weapon_slot[ "weapon_system" ].shoot( slot_node, position.direction_to( closest_target.position ), self )

func enable_weapon_slots( ) :
	var slot_num = 0
	for weapon_slot in weapon_slots :
		if not weapon_slot[ "enabled" ] and weapon_slot[ "level_unlocked" ] <= level :
			var weapon_slot_name = "Pivot/weapon_slot_%s" % slot_num
			var weapon_slot_path = NodePath( weapon_slot_name )
			var weapon_slot_node = get_node( weapon_slot_path )
			weapon_slot[ "enabled" ] = true
			weapon_slot[ "weapon_system" ] = weapon_system.instantiate( )
			weapon_slot[ "weapon_system" ].initialize( level, slot_num, character_num, weapon_slot[ "weapons_available" ] )
			weapon_slot[ "weapon_system" ].weapon_active_status.connect( self.weapon_active_status )
			weapon_slot[ "weapon_system" ].weapon_stays_active.connect( self.weapon_stays_active )
			weapon_slot_node.add_child( weapon_slot[ "weapon_system" ] )
			# Display a model if it has one.
			if weapon_slot[ "weapon_system" ].get_weapon_property( "model" ) != null :
				# Blades are slots 1 and 2
				print( "Enemy ", character_num, " enabled the ", weapon_slot[ "weapon_system" ].get_weapon_property( "model" ), " model on slot ", slot_num )
				if slot_num > 0 and slot_num < 3 :
					weapon_slot[ "weapon" ] = blade.instantiate( )
					weapon_slot[ "weapon" ].initialize( weapon_slot_node.position, self, weapon_slot[ "weapon_system" ].get_weapon_properties( ) )
					weapon_slot_node.add_child( weapon_slot[ "weapon" ] )
					if slot_num == 1 :
						weapon_slot[ "weapon" ].position.x = 0.0
						weapon_slot[ "weapon" ].position.y = 0.0
						weapon_slot[ "weapon" ].position.z = 0.75
						weapon_slot[ "weapon" ].rotation.x = 2.09
						weapon_slot[ "weapon" ].rotation.y = 0.0
						weapon_slot[ "weapon" ].rotation.z = 0.0
					else :
						weapon_slot[ "weapon" ].position.x = -0.75
						weapon_slot[ "weapon" ].position.y = -0.224
						weapon_slot[ "weapon" ].position.z = -0.75
						weapon_slot[ "weapon" ].rotation.x = 1.047
						weapon_slot[ "weapon" ].rotation.y = 0.0
						weapon_slot[ "weapon" ].rotation.z = 0.0
		slot_num += 1

func update_target_location( ) :
	set_closest_target( )

func _on_navigation_agent_3d_target_reached( ) :
	#print( "Enemy : Target in range!" )
	set_closest_target( )

func _on_navigation_agent_3d_velocity_computed( safe_velocity ) :
	#safe_velocity.y = 0
	#if notification_change :
	#	print( "Enemy : ", character_num, " Safe Velocity : ", safe_velocity )
	velocity = velocity.direction_to( safe_velocity * base_speed ) * base_speed
	velocity.normalized( )
	move_and_slide( )

func is_player( ) :
	return false

func get_level( ) :
	return level

func get_weapon_slots( ) :
	return weapon_slots

func weapon_active_status( slot : int, status : bool ) :
	print( "Enemy ", character_num, " weapon slot ", slot, " Weapon active status is called : ", status )

func weapon_stays_active( slot : int, status : bool ) :
	print( "Enemy ", character_num, " weapon slot ", slot, " Weapon stays active is called : ", status )
