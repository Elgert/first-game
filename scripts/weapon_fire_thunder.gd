extends Node2D

class_name WeaponFireThunder

# Weapon properties
@export var weapon_name = "Fire Thunder"
@export var damage = 30
@export var attack_interval = 5.0 # Strike every 5 seconds
@export var attack_range = 600.0
@export var level = 1
@export var max_level = 5
@export var strike_count = 1 # Number of strikes per activation

# Internal variables
var timer = 0.0
var available_targets = []
var strike_effect_scene = preload("res://scenes/effects/thunder_strike.tscn")

func _ready():
	# Initialize the timer to start with a small delay
	timer = randf_range(0.5, 1.5)

func _physics_process(delta):
	# Update the timer
	timer -= delta

	if timer <= 0:
		# Try to find targets and attack
		attack()

		# Reset the timer
		timer = attack_interval

# Find random enemies within range and strike them
func attack():
	# Get all enemies in the scene
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	available_targets.clear()

	# Filter enemies within range
	for enemy in all_enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= attack_range:
			available_targets.append(enemy)

	if available_targets.size() == 0:
		return # No targets available

	# Calculate number of strikes to perform
	var strikes_to_do = min(strike_count, available_targets.size())

	# Shuffle the targets list
	available_targets.shuffle()

	# Perform the strikes
	for i in range(strikes_to_do):
		var target = available_targets[i]
		strike(target)

# Perform a thunder strike on a target
func strike(target):
	# Create the visual effect
	var strike_effect = strike_effect_scene.instantiate()
	strike_effect.target = target
	strike_effect.damage = damage

	# Add effect to the scene
	get_tree().root.add_child(strike_effect)

	# Play sound effect if available
	if has_node("ThunderSound"):
		$ThunderSound.play()

# Called after upgrading to handle any special logic
func _after_upgrade():
	pass
