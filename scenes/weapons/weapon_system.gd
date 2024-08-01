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
var weapon_list = [
	{
		"name" : "Laser Pistol",
		"scene_name" : "laser_pistol",
		"damage" : 2,
		"rate_of_fire" : 3,
		"speed" : 50,
		"energy_cost" : 1,
		"range" : 100,
		"level_required" : 1,
		"enabled" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
		"model" : null,
	}, {
		"name" : "Blade",
		"scene_name" : "blade",
		"damage" : 0.1,
		"rate_of_fire" : 4,
		"speed" : 10,
		"energy_cost" : 5,
		"range" : 2.0,
		"level_required" : 3,
		"enabled" : true,
		"stays_active" : true,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
		"model" : "blade",
	}, {
		"name" : "Laser Rifle",
		"scene_name" : "laser_rifle",
		"damage" : 5,
		"rate_of_fire" : 5,
		"speed" : 50,
		"energy_cost" : 5,
		"range" : 100,
		"level_required" : 5,
		"enabled" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
		"model" : null,
	}, {
		"name" : "Laser Blaster",
		"scene_name" : "laser_blaster",
		"damage" : 4,
		"rate_of_fire" : 5,
		"speed" : 50,
		"energy_cost" : 4,
		"range" : 100,
		"level_required" : 7,
		"enabled" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
		"model" : "blaster",
	}, {
		"name" : "Laser Repeater",
		"scene_name" : "laser_repeater",
		"damage" : 1,
		"rate_of_fire" : 10,
		"speed" : 50,
		"energy_cost" : 1,
		"range" : 100,
		"level_required" : 9,
		"enabled" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
		"model" : "blaster",
	}, {
		"name" : "Plasma Blaster",
		"scene_name" : "plasma_blaster",
		"damage" : 10,
		"rate_of_fire" : 5,
		"speed" : 40,
		"energy_cost" : 15,
		"range" : 100,
		"level_required" : 11,
		"enabled" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : true,
		"target_lock" : false,
		"model" : "blaster",
	}, {
		"name" : "Plasma Cannon",
		"scene_name" : "plasma_cannon",
		"damage" : 20,
		"rate_of_fire" : 5,
		"speed" : 40,
		"energy_cost" : 25,
		"range" : 100,
		"level_required" : 13,
		"enabled" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : true,
		"target_lock" : false,
		"model" : "zooka",
	}, {
		"name" : "Rail Gun",
		"scene_name" : "rail_gun",
		"damage" : 20,
		"rate_of_fire" : 5,
		"speed" : 50,
		"energy_cost" : 15,
		"range" : 100,
		"level_required" : 15,
		"enabled" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
		"model" : "zooka",
	}, {
		"name" : "Missile",
		"scene_name" : "missile",
		"damage" : 20,
		"rate_of_fire" : 5,
		"speed" : 40,
		"energy_cost" : 10,
		"range" : 100,
		"level_required" : 20,
		"enabled" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
		"model" : "zooka",
	}, {
		"name" : "Homing Missile",
		"scene_name" : "missile",
		"damage" : 20,
		"rate_of_fire" : 5,
		"speed" : 40,
		"energy_cost" : 10,
		"range" : 100,
		"level_required" : 25,
		"enabled" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : true,
		"model" : "zooka",
	}, {
		"name" : " Jolt",
		"scene_name" : "jolt",
		"damage" : 10,
		"rate_of_fire" : 5,
		"speed" : 15,
		"energy_cost" : 10,
		"range" : 5.0,
		"level_required" : 50,
		"enabled" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
		"model" : null,
	}, 
]

var default_active_weapon = 0
@export var active_weapon = default_active_weapon

var character = 0
var time_last_shot = 0
var time_shot = 0

func initialize( weapon : int, slot : int, character_num : int ) :
	character = character_num
	set_weapon( weapon, slot )

func get_weapon( slot : int ) :
	print( "Weapon is : ", get_weapon_name( ) )
	return weapon_list[ active_weapon ]

func set_weapon( weapon : int, slot : int ) :
	set_active( false, slot )
	active_weapon = weapon
	print( "Weapon slot ", slot, " set to : ", get_weapon_name( ) )
	set_active( true, slot )

func get_weapon_name( ) :
	return weapon_list[ active_weapon ][ "name" ]

func get_weapon_range( ) :
	return weapon_list[ active_weapon ][ "range" ]

func get_weapon_rof( ) :
	return weapon_list[ active_weapon ][ "rate_of_fire" ]

func get_weapons_list( ) :
	return weapon_list

func set_active( setting : bool, slot : int ) :
	if stays_active( ) :
		print( "Setting active flag to : ", setting )
		weapon_list[ active_weapon ][ "active" ] = setting
		var wielder = get_parent( )
		var group_fmt = "player%sweapon"
		if not wielder.is_player :
			group_fmt = "enemy%sweapon"
		var group_name = group_fmt % wielder.character_num
		if get_tree( ) != null :
			for weapon in get_tree( ).get_nodes_in_group( group_name ) :
				if not setting :
					weapon.deactivate( )
				else :
					weapon.activate( )
		else :
			print( "No weapon tree!" )

func is_active( ) :
	return weapon_list[ active_weapon ][ "active" ]

func stays_active( ) :
	return weapon_list[ active_weapon ][ "stays_active" ]

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
func cycle_up( slot : Dictionary, wrap : bool ) :
	var weapon_index = 0
	if slot[ "weapon" ] != null :
		weapon_index = get_weapon_index( slot[ "weapons_available" ], slot[ "weapon" ] )
	var weapon = weapon_index + 1
	if weapon >= slot[ "weapons_available" ].size( ) :
		if wrap :
			weapon = 0
		else :
			# We don't wrap around and stay at the stongest weapon
			weapon = weapon_index
	
	return slot[ "weapons_available" ][ weapon ]

func cycle_down( slot : Dictionary, wrap : bool ) :
	var weapon_index = 0
	if slot[ "weapon" ] != null :
		weapon_index = get_weapon_index( slot[ "weapons_available" ], slot[ "weapon" ] )
	var weapon = weapon_index - 1
	if weapon < 0 :
		if wrap :
			weapon = slot[ "weapons_available" ].size( ) - 1
		else :
			# We don't wrap around and stay at the stongest weapon
			weapon = weapon_index
	
	return slot[ "weapons_available" ][ weapon ]

func get_energy_cost( ) :
	return weapon_list[ active_weapon ][ "energy_cost" ]

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

func spawn_weapon( shot_spawn_location, look_direction, shooter, slot ) :
	time_last_shot = time_shot
	var shot_scene = instantiate_scene( )
	if shot_scene != null :
		shot_scene.initialize( shot_spawn_location.global_position, look_direction, shooter, weapon_list[ active_weapon ] )
		add_child( shot_scene )

func shoot( shot_spawn_location, look_direction, shooter ) :
	time_shot = Time.get_ticks_msec( )
	if time_shot - time_last_shot > ( 1000 / get_weapon_rof( ) ) :
		for slot in shooter.get_weapon_slots( ) :
			if slot[ "enabled" ] :
				spawn_weapon( shot_spawn_location, look_direction, shooter, slot )

