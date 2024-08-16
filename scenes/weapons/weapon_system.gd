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

@onready var weapon_scenes = {
	"jolt" : jolt,
	"blade" : blade,
	"laser_pistol" : laser_pistol,
	"laser_rifle" : laser_rifle,
	"laser_blaster" : laser_blaster,
	"laser_repeater" : laser_repeater,
	"plasma_blaster" : plasma_blaster,
	"plasma_cannon" : plasma_cannon,
	"rail_gun" : rail_gun,
	"missile" : missile,
}

# Weapons
# Rate of fire is in shots per second
# Gravity is boolean for if shots are affected by gravity or not.
var weapon_data = preload( "res://scenes/weapons/weapon_data.gd" )
var weapon_list
var weapon_slot

var default_active_weapon = 0
@export var active_weapon = default_active_weapon

var character = 0
var time_last_shot = 0
var time_shot = 0

signal weapon_active_status
signal weapon_stays_active
signal weapon_scene

func initialize( level : int, slot_num : int, character_num : int, available_weapons : Array, wielder ) :
	weapon_slot = slot_num
	weapon_list = weapon_data.new( )
	character = character_num
	var weapon = get_best_weapon( level, available_weapons )
	set_weapon( weapon, weapon_slot )
	wielder.shoot.connect( self.shoot )
	wielder.weapon_cycle_up.connect( self.cycle_up )
	wielder.weapon_cycle_down.connect( self.cycle_down )
	wielder.weapon_set.connect( self.set_weapon )
	#wielder.set_weapon_activation.connect( self.set_weapon_property )

func get_weapon( ) :
	return active_weapon

func get_weapon_properties( ) :
	return weapon_list.get_weapon_properties( active_weapon )

func get_weapon_property( property_name : String ) :
	return weapon_list.get_weapon_property( active_weapon, property_name )

func get_best_weapon( level : int, available_weapons : Array ) :
	var weapon_index = null
	for available_weapon_index in available_weapons :
		if level < weapon_list.get_weapon_property( available_weapon_index, "level_required" ) :
			break
		else :
			weapon_index = available_weapon_index
	
	return weapon_index

func set_weapon( weapon : int, slot_num : int ) :
	active_weapon = weapon

func get_weapon_index( weapons : Array, weapon_match : int ) :
	var w_index = 0;
	for weapon in weapons :
		if weapon == weapon_match :
			break
		w_index += 1
	return w_index

# We need to validate that we only cycle through weapons
# that can be fit into the provided slot
func cycle_up( weapons_available : Array, wrap_around : bool ) :
	var index = get_weapon_index( weapons_available, active_weapon )
	var new_index = index + 1
	if new_index >= weapons_available.size( ) :
		if wrap_around :
			index = 0
		# or else nothing changes
	else :
		index = new_index
		
	return weapons_available[ index ]

func cycle_down( weapons_available : Array, wrap_around : bool ) :
	var index = get_weapon_index( weapons_available, active_weapon )
	var new_index = index - 1
	if new_index < 0 :
		if wrap_around :
			index = weapons_available.size( ) - 1
	else :
		index = new_index
	
	return weapons_available[ index ]

func shoot( slot_num : int ) :
	time_shot = Time.get_ticks_msec( )
	if time_shot - time_last_shot > ( 1000 / weapon_list.get_weapon_property( active_weapon, "rate_of_fire" ) ) :
		var scene_name = weapon_list.get_weapon_property( active_weapon, "scene_name" )
		if scene_name != null :
			weapon_scene.emit( weapon_scenes[ scene_name ].instantiate( ), weapon_list.get_weapon_properties( active_weapon ), slot_num )
			time_last_shot = time_shot
		else :
			print( "ERROR : No scene name" )
