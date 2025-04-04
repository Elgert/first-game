extends Node2D

class_name WeaponBase

# Weapon properties
@export var weapon_name = "Base Weapon"
@export var damage = 10
@export var attack_speed = 1.0 # Attacks per second
@export var attack_range = 200.0
@export var level = 1
@export var max_level = 8

# Internal variables
var cooldown_timer = 0.0
var cooldown = 1.0 # Will be set based on attack_speed
var target = null

# References
@onready var owner_node = get_parent()

func _ready():
	# Initialize weapon
	cooldown = 1.0 / attack_speed

func _physics_process(delta):
	# Handle cooldown
	cooldown_timer -= delta

	# Check if can attack
	if cooldown_timer <= 0:
		# Find targets and attack
		attack()

		# Reset cooldown
		cooldown_timer = cooldown

# Virtual function to be overridden by specific weapons
func attack():
	print("Base weapon attack - override this!")

# Find nearest enemy within range
func find_target():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_enemy = null
	var closest_distance = attack_range

	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_enemy = enemy
			closest_distance = distance

	return closest_enemy

# Level up the weapon
func upgrade():
	if level < max_level:
		level += 1
		# This method is no longer used - upgrades are handled in weapon_manager
		return true
	return false

# Apply stat upgrades based on level
func _apply_upgrade():
	# Removed - upgrade logic handled in weapon_manager
	pass

# Called by the weapon manager after applying upgrade stats
func _after_upgrade():
	# Update cooldown based on new attack speed
	cooldown = 1.0 / attack_speed
