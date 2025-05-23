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
	print("Spawning fireballs: ", fireball_count)
	# Clear existing fireballs first
	for ball in fireballs:
		if is_instance_valid(ball):
			ball.queue_free()
	fireballs.clear()

	# Create new fireballs with even spacing
	for i in range(fireball_count):
		var fireball = fireball_scene.instantiate()
		var offset = (2 * PI / fireball_count) * i

		# Configure fireball properties
		fireball.damage = damage
		fireball.orbit_speed = orbit_speed
		fireball.orbit_distance = orbit_distance
		fireball.orbit_offset = offset # Even spacing

		print("Fireball #" + str(i) + " - Offset: " + str(offset) + " radians (" + str(offset * 180 / PI) + " degrees)")

		add_child(fireball)
		fireballs.append(fireball)

	print("Total fireballs created: ", fireballs.size())

# Level up the weapon
func upgrade():
	if level < max_level:
		level += 1
		# This method is no longer used - upgrades are handled in weapon_manager
		return true
	return false

# This method is no longer used - upgrades are handled in weapon_manager
# Apply stat upgrades based on level
func _apply_upgrade():
	# Removed internal upgrade logic - handled in weapon_manager
	pass

# Called by the weapon manager after applying upgrade stats
func _after_upgrade():
	# Respawn fireballs with new configuration
	spawn_fireballs()
