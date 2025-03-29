extends Node2D

class_name WeaponOrbit

# Weapon properties
@export var weapon_name = "Orbit Fireballs"
@export var damage = 15
@export var orbit_speed = 0.6 # Reduced from 2.0 (about 3.3x slower)
@export var level = 1
@export var max_level = 5
@export var fireball_count = 1

# Orbit settings
var orbit_distance = 100.0
var fireball_scene = preload("res://scenes/weapons/orbit_fireball.tscn")
var fireballs = []

func _ready():
	# Create initial fireballs
	spawn_fireballs()

func spawn_fireballs():
	# Clear existing fireballs first
	for ball in fireballs:
		if is_instance_valid(ball):
			ball.queue_free()
	fireballs.clear()

	# Create new fireballs with even spacing
	for i in range(fireball_count):
		var fireball = fireball_scene.instantiate()

		# Configure fireball properties
		fireball.damage = damage
		fireball.orbit_speed = orbit_speed
		fireball.orbit_distance = orbit_distance
		fireball.orbit_offset = (2 * PI / fireball_count) * i # Even spacing

		add_child(fireball)
		fireballs.append(fireball)

# Level up the weapon
func upgrade():
	if level < max_level:
		level += 1
		_apply_upgrade()
		return true
	return false

# Apply stat upgrades based on level
func _apply_upgrade():
	# Apply upgrades based on level
	match level:
		2:
			# Level 2: Add another fireball
			fireball_count += 1
			damage = int(damage * 1.2)
		3:
			# Level 3: Increase damage and speed
			damage = int(damage * 1.3)
			orbit_speed *= 1.2
		4:
			# Level 4: Add another fireball
			fireball_count += 1
			damage = int(damage * 1.2)
		5:
			# Level 5: Max level - add 2 more fireballs and increase damage
			fireball_count += 2
			damage = int(damage * 1.5)
			orbit_speed *= 1.2

	# Respawn all fireballs with new configuration
	spawn_fireballs()
