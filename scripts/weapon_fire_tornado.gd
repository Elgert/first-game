extends Node2D

class_name WeaponFireTornado

# Weapon properties
@export var weapon_name = "Fire Tornado"
@export var damage = 20
@export var attack_interval = 6.0 # Seconds between tornado summons
@export var attack_range = 1000.0 # How far the tornado travels
@export var level = 1
@export var max_level = 5
@export var tornado_count = 1 # Number of tornadoes to summon at once
@export var tornado_speed = 150.0 # Speed of tornado movement

# Internal variables
var timer = 0.0
var tornado_scene = preload("res://scenes/weapons/fire_tornado.tscn")
var active_tornadoes = []

func _ready():
	# Initialize the timer to start with a small delay
	timer = randf_range(0.5, 1.5)

func _physics_process(delta):
	# Update the timer
	timer -= delta

	if timer <= 0:
		# Summon tornado(s)
		summon_tornadoes()

		# Reset the timer
		timer = attack_interval

# Summon tornadoes in different directions
func summon_tornadoes():
	# Base angle for first tornado
	var base_angle = randf() * 2 * PI

	# Clear any dead tornadoes from the list
	_clean_tornado_list()

	# Calculate angle offset for multiple tornadoes (distributed evenly)
	var angle_offset = 2 * PI / tornado_count

	# Spawn tornadoes
	for i in range(tornado_count):
		var angle = base_angle + (angle_offset * i)
		var direction = Vector2(cos(angle), sin(angle))

		summon_single_tornado(direction)

# Summon a single tornado
func summon_single_tornado(direction):
	var tornado = tornado_scene.instantiate()

	# Set tornado properties
	tornado.damage = damage
	tornado.speed = tornado_speed
	tornado.max_distance = attack_range
	tornado.direction = direction
	tornado.source = get_parent() # The player

	# Set position at the player rather than at a distance
	tornado.global_position = get_parent().global_position

	# Add to the scene
	get_tree().root.add_child(tornado)
	active_tornadoes.append(tornado)

# Clean up the list of active tornadoes, removing any that are no longer valid
func _clean_tornado_list():
	var valid_tornadoes = []
	for tornado in active_tornadoes:
		if is_instance_valid(tornado):
			valid_tornadoes.append(tornado)
	active_tornadoes = valid_tornadoes

# Level up the weapon
func upgrade():
	if level < max_level:
		level += 1
		_apply_upgrade()
		return true
	return false

# Apply stat upgrades based on level
func _apply_upgrade():
	# Removed internal upgrade logic - handled in weapon_manager
	pass

# Called by the weapon manager after applying upgrade stats
func _after_upgrade():
	# Any specific post-upgrade actions can be implemented here
	pass
