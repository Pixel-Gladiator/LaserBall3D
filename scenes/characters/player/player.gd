extends CharacterBody3D

#signal shoot( shot )
var ui_scene_players = [ ]
var multiplayer_data = [
	{
		"name" : "",
		"health" : 0.0,
		"energy" : 0.0,
		"experience" : 0.0,
	}
]

# Weapons
@export var weapon_system: PackedScene

@onready var booster = $Pivot/booster/player_boost
@onready var blaster_L = $Pivot/weapon_slot_2/blaster
@onready var blaster_R = $Pivot/weapon_slot_3/blaster
@onready var zooka_L = $Pivot/weapon_slot_4/zooka
@onready var zooka_R = $Pivot/weapon_slot_5/zooka

###############################################################################
# Player Default/Starting Values
###############################################################################
# How fast the player moves in meters per second.
var default_speed = 8
var default_sprint = false
var default_sprint_energy = 0.1
var default_sprint_speed_multiplier = 2
# Player Hit points
var default_health = 100.0
# Health Regeneration Rate
var default_health_regeneration_rate = 0
# Player Energy level
var default_energy = 100
# Energy Regeneration Rate
var default_energy_regeneration_rate = 0.5

# Weapon shot speed
var default_shot_speed = 100
# Weapon shot damage
var default_shot_damage = 1

###############################################################################
# How many weapons slots are available
var weapon_slots = [
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"weapon_system" : null,
		"level_unlocked" : 3,
		"weapons_available" : [ 1, 2, 3 ],
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"weapon_system" : null,
		"level_unlocked" : 1,
		"weapons_available" : [ 0, 10 ],
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"weapon_system" : null,
		"level_unlocked" : 10,
		"weapons_available" : [ 4, 5, 7 ],
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"weapon_system" : null,
		"level_unlocked" : 10,
		"weapons_available" : [ 4, 5, 7 ],
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"weapon_system" : null,
		"level_unlocked" : 10,
		"weapons_available" : [ 6, 8, 9 ],
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"weapon_system" : null,
		"level_unlocked" : 10,
		"weapons_available" : [ 6, 8, 9 ],
	},
]
var active_weapon_slot = 20
var weapon_slots_available = 0

# How fast the player moves in meters per second.
var speed = default_speed
var sprint = default_sprint
var sprint_energy = default_sprint_energy
var sprint_speed_multiplier = default_sprint_speed_multiplier
# Player Hit points
var health = default_health
var health_max = default_health
# Health Regeneration Rate
var health_regeneration_rate = default_health_regeneration_rate
# Player Energy level
var energy = default_energy
var energy_max = default_energy
# Energy Regeneration Rate
var energy_regeneration_rate = default_energy_regeneration_rate

###############################################################################
# Player Level
@export var level = 1
# The player's score
@export var score = 0
# Player experience points
@export var experience = 0
var experience_for_next_level = 100

# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

@export var sprinting = false
@export var shooting = false
@export var can_regenerate = true
###############################################################################

# Global Values
###############################################################################
var target_velocity = Vector3.ZERO

var default_active_weapon = 0
var active_weapon = default_active_weapon
var direction_facing = Vector3.FORWARD * -1
var default_colour = Color( 0.0, 0.0, 1.0, 1 )
@export var player_colour = default_colour

var energy_collected = 0
var character_num = 0

signal shoot( slot_number : int )
signal weapon_cycle_up( wrap : bool )
signal weapon_cycle_down( wrap : bool )
signal weapon_set( weapon_index : int, weapon_slot : int )
signal set_weapon_activation( weapon_slot : int )
signal death( character_num : int )

# Functions
###############################################################################
func initialize( spawn_point ) :
	position = spawn_point.position
	position.y += 0.1
	var material = $Pivot/model/body.mesh.surface_get_material( 0 )
	if material :
		material.albedo_color = player_colour
	
	add_to_group( "players" )
   
func _ready( ) :
	# How fast the player moves in meters per second.
	speed = default_speed
	sprint = default_sprint
	sprint_energy = default_sprint_energy
	sprint_speed_multiplier = default_sprint_speed_multiplier
	# Player Hit points
	health = default_health
	health_max = default_health
	# Health Regeneration Rate
	health_regeneration_rate = default_health_regeneration_rate
	# Player Energy level
	energy = default_energy
	energy_max = default_energy
	# Energy Regeneration Rate
	energy_regeneration_rate = default_energy_regeneration_rate
	# Player Level
	level = 1
	# The player's score
	score = 0
	# Player experience points
	experience = 500
	active_weapon = default_active_weapon
	var players = get_tree( ).get_nodes_in_group( "players" )
	for player in players :
		character_num += 1
	print( "Player ", character_num, " has joined the game" )
	enable_weapon_slots( )

func enable_weapon_slots( ) :
	var slot_num = 0
	for weapon_slot in weapon_slots :
		if not weapon_slot[ "enabled" ] and weapon_slot[ "level_unlocked" ] <= level :
			weapon_slot[ "enabled" ] = true
			weapon_slot[ "weapon_system" ] = weapon_system.instantiate( )
			weapon_slot[ "weapon_system" ].initialize( level, slot_num, character_num, weapon_slot[ "weapons_available" ], self )
			weapon_slot[ "weapon_system" ].weapon_active_status.connect( self.weapon_active_status )
			weapon_slot[ "weapon_system" ].weapon_stays_active.connect( self.weapon_stays_active )
			weapon_slot[ "weapon_system" ].weapon_scene.connect( self.launch_weapon_scene )
			add_child( weapon_slot[ "weapon_system" ] )
		slot_num += 1

func regeneration( ) :
	energy += energy_regeneration_rate
	if energy > energy_max :
		energy = energy_max
	
	health += health_regeneration_rate
	if health > health_max :
		health = health_max

func level_up( ) :
	while experience >= experience_for_next_level :
		experience_for_next_level *= 2
		level += 1
		enable_weapon_slots( )
		get_node( "/root/World" ).set_highest_player_level( )

func launch_weapon_scene( weapon_scene, weapon_properties, slot_num ) :
	if weapon_scene != null :
		#var shot_scene = weapon_scene.instantiate( )
		var slot_name = "Pivot/weapon_slot_%s" % slot_num
		var slot_path = NodePath( slot_name )
		var slot_node = get_node( slot_path )
		var world = get_node( "/root/World" )
		if weapon_properties.scene_name != "blade" :
			print( "Slot : ", slot_name )
			weapon_scene.initialize( slot_node.global_position, direction_facing, self, weapon_properties )
			world.add_child( weapon_scene )
		else :
			if not weapon_properties.active :
				weapon_scene.initialize( slot_path, direction_facing, self, weapon_properties )
				weapon_scene.state.connect( self.weapon_active_status )
				slot_node.add_child( weapon_scene )
		if weapon_scene.has_method( "activate" ) :
			set_weapon_activation.emit( )
		energy -= weapon_properties.energy_cost
	else :
		print( "ERROR : weapon scene is null" )

func weapon_shot( weapon_slot, slot_num ) :
	if weapon_slot[ "enabled" ] :
		var slot_name = "Pivot/weapon_slot_%s" % slot_num
		var slot_path = NodePath( slot_name )
		var slot_node = get_node( slot_path )
		if energy > weapon_slot[ "weapon_system" ].get_weapon_property( "energy_cost" ) :
			shoot.emit( slot_num )

func weapon_shoot( ) :
	if active_weapon_slot > weapon_slots.size( ) :
		var slot_num = 0
		for weapon_slot in weapon_slots :
			weapon_shot( weapon_slot, slot_num )
			slot_num += 1
	else :
		weapon_shot( weapon_slots[ active_weapon_slot ], active_weapon_slot )

func _process( _delta ) :
	if can_regenerate :
		regeneration( )
	# Handle weapon changes
	if Input.is_action_just_pressed( "weapon_cycle_up" ) :
		weapon_cycle_up.emit( true )
	if Input.is_action_just_pressed( "weapon_cycle_down" ) :
		weapon_cycle_down.emit( true )
	if Input.is_action_just_pressed( "weapon_1" ) :
		weapon_set.emit( 0, 0 )
	if Input.is_action_just_pressed( "weapon_2" ) :
		weapon_set.emit( 1, 1 )
	if Input.is_action_just_pressed( "weapon_3" ) :
		weapon_set.emit( 2, 0 )
	if Input.is_action_just_pressed( "weapon_4" ) :
		weapon_set.emit( 3, 0 )
	if Input.is_action_just_pressed( "weapon_5" ) :
		weapon_set.emit( 4, 2 )
		weapon_set.emit( 4, 3 )
	if Input.is_action_just_pressed( "weapon_6" ) :
		weapon_set.emit( 5, 2 )
		weapon_set.emit( 5, 3 )
	if Input.is_action_just_pressed( "weapon_7" ) :
		weapon_set.emit( 6, 4 )
		weapon_set.emit( 6, 5 )
	if Input.is_action_just_pressed( "weapon_8" ) :
		weapon_set.emit( 7, 2 )
		weapon_set.emit( 7, 3 )
	if Input.is_action_just_pressed( "weapon_9" ) :
		if active_weapon == 8 :
			weapon_set.emit( 9, 4 )
			weapon_set.emit( 9, 5 )
		else :
			weapon_set.emit( 8, 4 )
			weapon_set.emit( 8, 5 )
	if Input.is_action_just_pressed( "weapon_10" ) :
		weapon_set.emit( 10, 1 )

	# Shooting
	if Input.is_action_just_pressed( "shoot" ) :
		weapon_shoot( )
		shooting = true
	elif Input.is_action_pressed( "shoot" ) and shooting :
		weapon_shoot( )
	else :
		shooting = false

func _physics_process( delta ) :
	var direction = Vector3.ZERO
	# Movement input checking
	if Input.is_action_pressed( "move_right" ) :
		direction.x -= 1
	if Input.is_action_pressed( "move_left" ) :
		direction.x += 1
	if Input.is_action_pressed( "move_backward" ) :
		direction.z -= 1
	if Input.is_action_pressed( "move_forward" ) :
		direction.z += 1
	
	if Input.is_action_pressed( "boost" ) and  energy > sprint_energy :
		sprint_speed_multiplier = default_sprint_speed_multiplier
		booster.activate( )
	else :
		sprint_speed_multiplier = 1
		booster.deactivate( )
	
	# Sprint energy consumption
	if sprint_speed_multiplier == default_sprint_speed_multiplier :
		energy -= sprint_energy
		if energy < 0 :
			energy = 0
		sprinting = true
		# If we're not moving and we boost, it will move us
		if direction == Vector3.ZERO :
			direction = direction_facing
	else :
		sprinting = false
	
	# Calculate ground Velocity
	target_velocity.x = direction.x * ( speed * sprint_speed_multiplier )
	target_velocity.z = direction.z * ( speed * sprint_speed_multiplier )
	
	# Vertical Velocity
	if not is_on_floor( ) :
		target_velocity.y = target_velocity.y - ( fall_acceleration * delta )
	
	if direction != Vector3.ZERO :
		direction = direction.normalized( )
		# Setting the basis property will affect the rotation of the node.
		$Pivot.basis = Basis.looking_at( direction * -1 )
		# Keep track of the direction we're facing, we need this for shooting
		direction_facing = direction
	
	if sprinting or shooting :
		can_regenerate = false
	else :
		can_regenerate = true
		
	# Moving the Character
	velocity = target_velocity
	move_and_slide( )

func hit( damage, _hit_position, _hitter ) :
	health -= damage
	var health_pct = ( health / default_health ) * 100.0
	if health <= 0 :
		death.emit( character_num )
		queue_free( )
	else :
		print( "Player health : ", health, " of ", default_health, " - ", health_pct, "%" )

func get_num( ) :
	return character_num

func is_player( ) :
	return true

func collect_energy( energy_amount ) :
	energy += energy_amount
	print( "Player Energy : ", energy )

func expend_energy( energy_amount ) :
	energy -= energy_amount
	print( "Player Energy : ", energy )

func add_experience( exp_amount ) :
	experience += exp_amount
	if experience >= experience_for_next_level :
		level_up( )

func get_experience( ) :
	return experience

func get_level( ) :
	return level

func weapon_active_status( status : bool ) :
	print( "Player ", character_num, " blade status : ", status )

func weapon_stays_active( slot_num : int, status : bool ) :
	print( "Player ", character_num, " weapon slot ", slot_num, " Weapon stays active : ", status )
