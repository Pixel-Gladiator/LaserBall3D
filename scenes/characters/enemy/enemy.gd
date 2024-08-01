extends CharacterBody3D

@onready var navigator = $NavigationAgent3D

@onready var blade_R = $Pivot/weapon_slot_1/blade
@onready var blade_L = $Pivot/weapon_slot_2/blade
@onready var blaster_R = $Pivot/weapon_slot_3/blaster
@onready var blaster_L = $Pivot/weapon_slot_4/blaster
@onready var zooka = $Pivot/weapon_slot_5/zooka

# Weapons
@export var weapon_system_scene: PackedScene
var weapon_system
var default_weapon = 0
var default_weapon_slot = 0
var weapon_slots = [
	{
		"enabled" : true,
		"equipped" : true,
		"weapon" : default_weapon,
		"level_unlocked" : 1,
		"weapons_available" : [ 0, 2, 3, 4 ],
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"level_unlocked" : 3,
		"weapons_available" : [ 1 ],
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"level_unlocked" : 3,
		"weapons_available" : [ 1 ],
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"level_unlocked" : 5,
		"weapons_available" : [ 5, 6 ],
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"level_unlocked" : 5,
		"weapons_available" : [ 5, 6 ],
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"level_unlocked" : 10,
		"weapons_available" : [ 7, 8, 9 ],
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
var weapon_list

signal add_to_enemy_energy_pool
signal add_experience_to_player
signal enemy_death

# This function will be called from the Main scene.
func initialize( start_position, id ) :
	# We position the mob by placing it at start_position
	look_at_from_position( start_position, global_position, Vector3.UP )
	
	character_num = id
	
	# We calculate a forward velocity that represents the speed.
	velocity = Vector3.FORWARD * base_speed
	# We then rotate the velocity vector based on the mob's Y rotation
	# in order to move in the direction the mob is looking.
	velocity = velocity.rotated( Vector3.UP, rotation.y )
	
	add_to_group( "enemies" )
	adjust_colour( )

func _ready( ) :
	var slot = 0
	weapon_system = weapon_system_scene.instantiate( )
	weapon_system.initialize( default_weapon, slot, character_num )
	add_child( weapon_system )
	
	weapon_list = weapon_system.get_weapons_list( )
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
			if position.distance_to( closest_target.position ) <= weapon_system.get_weapon_range( ) :
				attack( )
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
	var is_player = true
	var groups = hitter.get_groups( )
	for group in groups :
		if group == "enemies" :
			is_player = false
	if is_player :
		health -= damage
		if health <= 0 :
			print( "Enemy was destroyed.  Collecting ", experience, " XP" )
			#player.add_experience( experience )
			add_experience_to_player.emit( hitter.get_num( ), experience )
			print( "Player ", hitter.get_num( ), " now has ", hitter.get_experience( ), " XP" )
			enemy_death.emit( )
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
	if energy_collected > 99 :
		level_up( )

func level_up( ) :
	# This is a workaround, these should never be null here
	if weapon_list == null :
		if weapon_system == null :
			weapon_system = weapon_system_scene.instantiate( )
			weapon_system.initialize( default_weapon, default_weapon_slot, character_num )
			add_child( weapon_system )
		weapon_list = weapon_system.get_weapons_list( )
	
	while energy_collected > 99 :
		energy_collected -= 100
		level += 1
		max_health = default_health * ( level / 2.0 )
		health = max_health
		adjust_colour( )
		print( "Enemy ", character_num, " is level ", level )
		experience = base_experience * level
		var slot = 0
		for weapon_slot in weapon_slots :
			var weapon_upgrade = false
			# Check each weapon slot to see if it is unlocked
			if level >= weapon_slot.level_unlocked :
				# Enable the weapon slot if it's not already
				if not weapon_slot.enabled :
					weapon_slot.enabled = true
				
				for weap_avail_index in weapon_slot.weapons_available :
					#print( "Weapon Index : ", weap_avail_index )
					if level >= weapon_list[ weap_avail_index ].level_required :
						if weapon_slot.weapon == null or weap_avail_index > weapon_slot.weapon :
							weapon_upgrade = true
							weapon_slot.weapon = weap_avail_index
			
			if weapon_upgrade :
				weapon_system.set_weapon( weapon_slot.weapon, slot )
			
			slot += 1

func attack( ) :
	var slot = 0
	for weapon_slot in weapon_slots :
		if weapon_slot[ "enabled" ] :
			var slot_name = "Pivot/weapon_slot_%s" % slot
			#print( "Slot : ", slot_name )
			var slot_path = NodePath( slot_name )
			#print( "Slot path : ", slot_path.get_concatenated_names( ) )
			var slot_node = get_node( slot_path )
			if weapon_slot[ "weapon" ] != null :
				if weapon_list[ weapon_slot[ "weapon" ] ][ "model" ] != null :
					slot_name = "Pivot/weapon_slot_%s/%s" % [ slot, weapon_list[ weapon_slot[ "weapon" ] ][ "model" ] ]
					slot_path = NodePath( slot_name )
					var model_node = get_node( slot_path )
					if model_node != null :
						print( "Enemy ", character_num, " attacking with weapon ", slot_name )
						model_node.visible = true
			
			if not weapon_system.stays_active( ) or ( weapon_system.stays_active( ) and not weapon_system.is_active( ) ) :
				if ( weapon_system.stays_active( ) and not weapon_system.is_active( ) ) :
					pass
				weapon_system.set_active( true, slot )
				weapon_system.shoot( slot_node, position.direction_to( closest_target.position ), self )
			
		slot += 1

func update_target_location( ) :
	set_closest_target( )

func _on_navigation_agent_3d_target_reached( ) :
	#print( "Enemy : Target in range!" )
	attack( )

func _on_navigation_agent_3d_velocity_computed( safe_velocity ) :
	#safe_velocity.y = 0
	#if notification_change :
	#	print( "Enemy : ", character_num, " Safe Velocity : ", safe_velocity )
	velocity = velocity.direction_to( safe_velocity * base_speed ) * base_speed
	velocity.normalized( )
	move_and_slide( )

func is_player( ) :
	return false

func get_weapon_slots( ) :
	return weapon_slots
