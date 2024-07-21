extends CharacterBody3D

#signal shoot( shot )

# Weapons
@export var weapon_system: PackedScene
var weapon

@export var player_boost: PackedScene
var booster

###############################################################################
# Player Default/Starting Values
###############################################################################
# How fast the player moves in meters per second.
var default_speed = 8
var default_sprint = false
var default_sprint_energy = 0.1
var default_sprint_speed_multiplier = 2
# Player Hit points
var default_health = 100
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
		"level_unlocked" : 1,
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"level_unlocked" : 5,
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"level_unlocked" : 10,
	},
	{
		"enabled" : false,
		"equipped" : false,
		"weapon" : null,
		"level_unlocked" : 10,
	},
]
var active_weapon_slot = 1
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

# Functions
###############################################################################
func initialize( spawn_point ) :
	position = spawn_point.position
	position.y += 0.1
	var material = $Pivot/model/body.mesh.surface_get_material( 0 )
	if material :
		material.albedo_color = player_colour
	
	weapon = weapon_system.instantiate( )
	weapon.initialize( active_weapon, active_weapon_slot, character_num )
	add_child( weapon )
	add_to_group( "players" )
	enable_weapon_slots( )
   
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
	experience = 0
	active_weapon = default_active_weapon
	var players = get_tree( ).get_nodes_in_group( "players" )
	for player in players :
		character_num += 1
		print( "Player ", character_num, " has joined the game" )
		
	booster = player_boost.instantiate( )
	booster.initialize( $Pivot/booster.global_position )
	add_child( booster )

func enable_weapon_slots( ) :
	for weapon_slot in weapon_slots :
		if weapon_slot[ "level_unlocked" ] >= level :
			weapon_slot[ "enabled" ] = true
		
		if weapon_slot[ "enabled" ] :
			weapon_slots_available += 1

func regeneration( ) :
	energy = energy + energy_regeneration_rate
	if energy > energy_max :
		energy = energy_max
	
	health = health + health_regeneration_rate
	if health > health_max :
		health = health_max

func add_experience( exp_amount ) :
	experience += exp_amount

func get_experience( ) :
	return experience

func level_up( ) :
	experience_for_next_level *= 2
	level += 1

func _process( _delta ) :
	if can_regenerate :
		regeneration( )
	if experience >= experience_for_next_level :
		level_up( )
	# Handle weapon changes
	if Input.is_action_just_pressed( "weapon_cycle_up" ) :
		weapon.cycle_up( active_weapon_slot )
	if Input.is_action_just_pressed( "weapon_cycle_down" ) :
		weapon.cycle_down( active_weapon_slot )
	if Input.is_action_just_pressed( "weapon_1" ) :
		weapon.set_weapon( 0 )
	if Input.is_action_just_pressed( "weapon_2" ) :
		weapon.set_weapon( 1 )
	if Input.is_action_just_pressed( "weapon_3" ) :
		weapon.set_weapon( 2 )
	if Input.is_action_just_pressed( "weapon_4" ) :
		weapon.set_weapon( 3 )
	if Input.is_action_just_pressed( "weapon_5" ) :
		weapon.set_weapon( 4 )
	if Input.is_action_just_pressed( "weapon_6" ) :
		weapon.set_weapon( 5 )
	if Input.is_action_just_pressed( "weapon_7" ) :
		weapon.set_weapon( 6 )
	if Input.is_action_just_pressed( "weapon_8" ) :
		weapon.set_weapon( 7 )
	if Input.is_action_just_pressed( "weapon_9" ) :
		if active_weapon == 8 :
			weapon.set_weapon( 9 )
		else :
			weapon.set_weapon( 8 )
	if Input.is_action_just_pressed( "weapon_10" ) :
		weapon.set_weapon( 10 )

	# Shooting
	if Input.is_action_just_pressed( "shoot" ) and energy > weapon.get_energy_cost( ) and weapon.stays_active( ) :
		print( "Weapon ", weapon.get_weapon_name( ), " stays active when fired" )
		var slot = 0
		for weapon_slot in weapon_slots :
			if weapon.is_active( ) :
				weapon.set_active( false, slot )
			
			else :
				if weapon_slot[ "enabled" ] :
					var slot_name = "Pivot/weapon_slot_%s" % slot
					#print( "Slot : ", slot_name )
					var slot_path = NodePath( slot_name )
					#print( "Slot path : ", slot_path.get_concatenated_names ( ) )
					var slot_node = get_node( slot_path )
					weapon.set_active( true, slot )
					energy -= weapon.get_energy_cost( )
					weapon.shoot( slot_node, direction_facing, self )
				slot += 1
			
		shooting = true
		
	elif Input.is_action_pressed( "shoot" ) and energy > weapon.get_energy_cost( ) and not weapon.stays_active( ) :
		var slot = 0
		for weapon_slot in weapon_slots :
			if weapon_slot[ "enabled" ] :
				var slot_name = "Pivot/weapon_slot_%s" % slot
				#print( "Slot : ", slot_name )
				var slot_path = NodePath( slot_name )
				#print( "Slot path : ", slot_path.get_concatenated_names ( ) )
				var slot_node = get_node( slot_path )
				weapon.set_active( true, slot )
				energy -= weapon.get_energy_cost( )
				weapon.shoot( slot_node, direction_facing, self )
			slot += 1
		shooting = true
		
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
	
	if Input.is_action_pressed( "sprint" ) and  energy > sprint_energy :
		sprint_speed_multiplier = default_sprint_speed_multiplier
		booster.activate( )
	else :
		sprint_speed_multiplier = 1
		booster.deactivate( )
	
	# Sprint energy consumption
	if sprint_speed_multiplier == default_sprint_speed_multiplier :
		energy = energy - sprint_energy
		if energy < 0 :
			energy = 0
		sprinting = true
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

func hit( damage, hit_position, hitter ) :
	health -= damage
	if health <= 0 :
		queue_free( )
	else :
		print( "Player hit : ", ( health / default_health ) * 100, "% health" )

func get_num( ) :
	return character_num

func is_player( ) :
	return true

func collect_energy( energy_amount ) :
	energy += energy_amount
	print( "Player Energy : ", energy )

func get_weapon_slots( ) :
	return weapon_slots
