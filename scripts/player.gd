extends CharacterBody2D

signal health_changed(new_health, max_health)
signal level_changed(new_level)
signal experience_changed(new_exp, next_level_exp)

const SPEED = 300.0

# Load weapon manager
const WeaponManager = preload("res://scripts/weapon_manager.gd")
var weapon_manager = null

# Player stats
var health = 100
var max_health = 100
var experience = 0
var level = 1
var experience_to_next_level = 10 # Lower value for faster leveling during testing

# Weapons and abilities
var weapons = []
var active_weapons = []

# Analog control variables
var analog_velocity = Vector2.ZERO
var using_analog = false

# Animation variables
var last_direction = "down"

@onready var basic_weapon = $BasicWeapon
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Initialize weapon manager
	weapon_manager = WeaponManager.new()

	# Initialize player
	emit_signal("health_changed", health, max_health)
	emit_signal("level_changed", level)
	emit_signal("experience_changed", experience, experience_to_next_level)

	# Ensure collision mask includes buildings (layer 2)
	set_collision_mask_value(2, true)

	# Set default animation
	animated_sprite.play("idle_down")

	# Store reference to the weapon
	if basic_weapon:
		weapons.append(basic_weapon)

func _physics_process(_delta):
	# Movement using analog input if available, otherwise keyboard
	if using_analog:
		velocity = analog_velocity * SPEED
	else:
		# Get keyboard input
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = input_dir * SPEED

	# Apply movement
	move_and_slide()

	# Update animation based on movement
	_update_animation()

func _update_animation():
	# Determine direction based on velocity
	var direction = "down" # Default

	if velocity.length() > 0:
		# Moving, determine direction
		if abs(velocity.x) > abs(velocity.y):
			# Horizontal movement is dominant
			direction = "right" if velocity.x > 0 else "left"
		else:
			# Vertical movement is dominant
			direction = "down" if velocity.y > 0 else "up"

		# Save last direction for idle state
		last_direction = direction

		# Play walking animation for current direction
		animated_sprite.play("walk_" + direction)
	else:
		# Not moving, play idle animation based on last direction
		animated_sprite.play("idle_" + last_direction)

# Called when the virtual analog stick is used
func set_analog_motion(input_vector):
	analog_velocity = input_vector
	using_analog = input_vector != Vector2.ZERO

# Take damage and check if player is dead
func take_damage(amount):
	health -= amount
	health = max(0, health)
	emit_signal("health_changed", health, max_health)

	if health <= 0:
		die()

# Heal the player
func heal(amount):
	health += amount
	health = min(health, max_health)
	emit_signal("health_changed", health, max_health)

# Die function
func die():
	# Game over logic
	set_physics_process(false)
	# Play death animation
	# Emit game over signal

# Add experience and check for level up
func add_experience(amount):
	experience += amount
	emit_signal("experience_changed", experience, experience_to_next_level)

	# Check for level up
	if experience >= experience_to_next_level:
		level_up()

# Level up function
func level_up():
	level += 1
	experience -= experience_to_next_level
	experience_to_next_level = int(experience_to_next_level * 1.2) # 20% increase per level

	# Increase stats
	max_health += 10
	health = max_health

	# Emit signals
	emit_signal("level_changed", level)
	emit_signal("health_changed", health, max_health)
	emit_signal("experience_changed", experience, experience_to_next_level)

# Apply a selected upgrade from the weapon manager
func apply_upgrade(weapon_type):
	if weapon_manager:
		return weapon_manager.apply_upgrade(self, weapon_type)
	return false

# Legacy upgrade methods (keeping for compatibility)
func increase_projectile_count():
	if basic_weapon and basic_weapon.has_method("upgrade"):
		basic_weapon.projectile_count += 1
		print("Upgrade applied: Projectile count increased to: ", basic_weapon.projectile_count)

func increase_firing_speed():
	if basic_weapon and basic_weapon.has_method("upgrade"):
		basic_weapon.attack_speed *= 1.2
		basic_weapon.cooldown = 1.0 / basic_weapon.attack_speed
		print("Upgrade applied: Firing speed increased to: ", basic_weapon.attack_speed)

func upgrade_orbit_fireballs():
	# This is now handled by the weapon manager
	pass

# Add a weapon directly (called from weapon manager)
func add_weapon(weapon_scene):
	var weapon = weapon_scene.instantiate()
	weapons.append(weapon)
	add_child(weapon)
