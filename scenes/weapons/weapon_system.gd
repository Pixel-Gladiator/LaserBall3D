extends Node

# Weapons
@export var jolt: PackedScene
@export var blade: PackedScene
@export var laser_pistol: PackedScene
@export var laser_rifle: PackedScene
@export var laser_blaster: PackedScene
@export var laser_repeater: PackedScene
@export var plasma_blaster: PackedScene
@export var plasma_cannon: PackedScene
@export var rail_gun: PackedScene
@export var missile: PackedScene

# Weapons
# Rate of fire is in shots per second
# Gravity is boolean for if shots are affected by gravity or not.
var weapon_data = preload( "res://scenes/weapons/weapon_data.gd" )
var weapon_list

var default_active_weapon = 0
@export var active_weapon = default_active_weapon

var character = 0
var time_last_shot = 0
var time_shot = 0

signal weapon_active_status
signal weapon_stays_active

func initialize( weapon : int, slot : int, character_num : int ) :
	weapon_list = weapon_data.new( )
	character = character_num
	set_weapon( weapon, slot )

func get_weapon( ) :
	return active_weapon

func get_weapon_properties( ) :
	return weapon_list.get_weapon_properties( active_weapon )

func get_weapon_property( property_name : String ) :
	return weapon_list.get_weapon_property( active_weapon, property_name )

func set_weapon( weapon : int, slot : int ) :
	set_active( false, slot )
	active_weapon = weapon
	set_active( true, slot )

func set_active( setting : bool, slot_num : int ) :
	if weapon_list.get_weapon_property( active_weapon, "stays_active" ) :
		weapon_stays_active.emit( slot_num, true )
		if weapon_list.get_weapon_property( active_weapon, "active" ) != setting :
			print( "Setting active flag to : ", setting, " for slot ", slot_num )
			weapon_list.set_weapon_active( active_weapon, setting )
		#var wielder = get_parent( )
		#var group_fmt = "player%sweapon"
		#if not wielder.is_player( ) :
			#group_fmt = "enemy%sweapon"
		#var group_name = group_fmt % wielder.character_num
		#if get_tree( ) != null :
			#for weapon in get_tree( ).get_nodes_in_group( group_name ) :
				#if not setting :
					#weapon.deactivate( )
				#else :
					#weapon.activate( )
		#else :
			#print( "No weapon tree!" )
	else :
		if weapon_list.get_weapon_property( active_weapon, "active" ) != setting :
			weapon_stays_active.emit( slot_num, false )
			print( "Setting active flag to : ", setting, " for slot ", slot_num )
			weapon_list.set_weapon_active( active_weapon, setting )

func get_weapon_index( weapons : Array, weapon_match : int ) :
	var w_index = 0;
	for weapon in weapons :
		if weapon == weapon_match :
			break
		w_index += 1
	return w_index

# We need to validate that we only cycle through weapons
# that can be fit into the provided slot
#		"enabled" : false,
#		"equipped" : false,
#		"weapon" : null,
#		"level_unlocked" : 1,
#		"weapons_available" : [ 0, 2, 3, 4 ],
func cycle_up( weapons_available : Array, wrap : bool ) :
	var index = get_weapon_index( weapons_available, active_weapon )
	var new_index = index + 1
	if new_index >= weapons_available.size( ) :
		if wrap :
			index = 0
		# or else nothing changes
	else :
		index = new_index
		
	return weapons_available[ index ]

func cycle_down( weapons_available : Array, wrap : bool ) :
	var index = get_weapon_index( weapons_available, active_weapon )
	var new_index = index - 1
	if new_index < 0 :
		if wrap :
			index = weapons_available.size( ) - 1
	else :
		index = new_index
	
	return weapons_available[ index ]

func instantiate_scene( ) :
	var scene
	if active_weapon == 0 :
		scene = laser_pistol
	elif active_weapon == 1 :
		scene = null
	elif active_weapon == 2 :
		scene = laser_rifle
	elif active_weapon == 3 :
		scene = laser_blaster
	elif active_weapon == 4 :
		scene = laser_repeater
	elif active_weapon == 5 :
		scene = plasma_blaster
	elif active_weapon == 6 :
		scene = plasma_cannon
	elif active_weapon == 7 :
		scene = rail_gun
	elif active_weapon == 8 :
		scene = missile
	elif active_weapon == 9 :
		scene = missile
	elif active_weapon == 10 :
		scene = jolt
	
	if scene == null :
		return scene
	else :
		return scene.instantiate( )

func spawn_weapon( shot_spawn_location, look_direction, shooter ) :
	time_last_shot = time_shot
	var shot_scene = instantiate_scene( )
	if shot_scene != null :
		shot_scene.initialize( shot_spawn_location.global_position, look_direction, shooter, weapon_list.get_weapon_properties( active_weapon ) )
		add_child( shot_scene )

func shoot( shot_spawn_location, look_direction, shooter ) :
	time_shot = Time.get_ticks_msec( )
	if time_shot - time_last_shot > ( 1000 / weapon_list.get_weapon_property( active_weapon, "rate_of_fire" ) ) :
		if weapon_list.get_weapon_property( active_weapon, "level_required" ) <= shooter.get_level( ) :
			spawn_weapon( shot_spawn_location, look_direction, shooter )
			weapon_active_status.emit( true )

