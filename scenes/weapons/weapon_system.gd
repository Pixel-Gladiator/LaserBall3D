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
		"damage" : 2,
		"rate_of_fire" : 3,
		"speed" : 50,
		"energy_cost" : 1,
		"range" : 100,
		"level_required" : 1,
		"is_usable" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
	}, {
		"name" : "Blade",
		"damage" : 0.1,
		"rate_of_fire" : 4,
		"speed" : 10,
		"energy_cost" : 5,
		"range" : 2.0,
		"level_required" : 1,
		"is_usable" : true,
		"stays_active" : true,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
	}, {
		"name" : "Laser Rifle",
		"damage" : 5,
		"rate_of_fire" : 5,
		"speed" : 50,
		"energy_cost" : 5,
		"range" : 100,
		"level_required" : 1,
		"is_usable" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
	}, {
		"name" : "Laser Blaster",
		"damage" : 4,
		"rate_of_fire" : 5,
		"speed" : 50,
		"energy_cost" : 4,
		"range" : 100,
		"level_required" : 1,
		"is_usable" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
	}, {
		"name" : "Laser Repeater",
		"damage" : 1,
		"rate_of_fire" : 10,
		"speed" : 50,
		"energy_cost" : 1,
		"range" : 100,
		"level_required" : 1,
		"is_usable" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
	}, {
		"name" : "Plasma Blaster",
		"damage" : 10,
		"rate_of_fire" : 5,
		"speed" : 40,
		"energy_cost" : 15,
		"range" : 100,
		"level_required" : 1,
		"is_usable" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : true,
		"target_lock" : false,
	}, {
		"name" : "Plasma Cannon",
		"damage" : 20,
		"rate_of_fire" : 5,
		"speed" : 40,
		"energy_cost" : 25,
		"range" : 100,
		"level_required" : 1,
		"is_usable" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : true,
		"target_lock" : false,
	}, {
		"name" : "Rail Gun",
		"damage" : 20,
		"rate_of_fire" : 5,
		"speed" : 50,
		"energy_cost" : 15,
		"range" : 100,
		"level_required" : 1,
		"is_usable" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
	}, {
		"name" : "Missile",
		"damage" : 20,
		"rate_of_fire" : 5,
		"speed" : 40,
		"energy_cost" : 10,
		"range" : 100,
		"level_required" : 1,
		"is_usable" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
	}, {
		"name" : "Homing Missile",
		"damage" : 20,
		"rate_of_fire" : 5,
		"speed" : 40,
		"energy_cost" : 10,
		"range" : 100,
		"level_required" : 1,
		"is_usable" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : true,
	}, {
		"name" : " Jolt",
		"damage" : 10,
		"rate_of_fire" : 3,
		"speed" : 15,
		"energy_cost" : 5,
		"range" : 5.0,
		"level_required" : 1,
		"is_usable" : true,
		"stays_active" : false,
		"active" : false,
		"gravity" : false,
		"target_lock" : false,
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

func get_weapon_name( ) :
	return weapon_list[ active_weapon ][ "name" ]

func get_weapon_range( ) :
	return weapon_list[ active_weapon ][ "range" ]

func get_rof( ) :
	return weapon_list[ active_weapon ][ "rate_of_fire" ]

func set_active( setting : bool, slot : int ) :
	if stays_active( ) :
		print( "Setting active flag to : ", setting )
		weapon_list[ active_weapon ][ "active" ] = setting
		if not setting :
			var wielder = get_parent( )
			var group_fmt = "player%sweapon"
			if not wielder.is_player :
				group_fmt = "enemy%sweapon"
			var group_name = group_fmt % wielder.character_num
			for weapon in get_tree( ).get_nodes_in_group( group_name ) :
				weapon.deactivate( )
	

func is_active( ) :
	return weapon_list[ active_weapon ][ "active" ]

func stays_active( ) :
	return weapon_list[ active_weapon ][ "stays_active" ]

func cycle_up( slot : int ) :
	var weapon = active_weapon + 1
	if weapon >= weapon_list.size( ) :
		weapon = 0
	set_weapon( weapon, slot )

func cycle_down( slot : int ) :
	var weapon = active_weapon - 1
	if weapon < 0 :
		weapon = weapon_list.size( ) - 1
	set_weapon( weapon, slot )

func get_energy_cost( ) :
	return weapon_list[ active_weapon ][ "energy_cost" ]

func instantiate_scene( ) :
	var scene
	if active_weapon == 0 :
		scene = laser_pistol
	elif active_weapon == 1 :
		scene = blade
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
	
	return scene.instantiate( )

func spawn_weapon( shot_spawn_location, look_direction, shooter, slot ) :
	var who = "Enemy"
	if shooter.is_player( ) :
		who = "Player"
	var shot_scene = instantiate_scene( )
	#print( who," ", shooter.character_num, " : ", time_shot - time_last_shot, " Shooting : ", get_weapon_name( ), " ROF : ", get_rof( ) )
	time_last_shot = time_shot
	shot_scene.initialize( shot_spawn_location.global_position, look_direction, shooter, weapon_list[ active_weapon ] )
	add_child( shot_scene )

func shoot( shot_spawn_location, look_direction, shooter ) :
	time_shot = Time.get_ticks_msec( )
	if time_shot - time_last_shot > ( 1000 / get_rof( ) ) :
		for slot in shooter.get_weapon_slots( ) :
			if slot[ "enabled" ] :
				spawn_weapon( shot_spawn_location, look_direction, shooter, slot )

