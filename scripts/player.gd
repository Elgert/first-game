extends CharacterBody2D

signal health_changed(new_health, max_health)
signal level_changed(new_level)
signal experience_changed(new_exp, next_level_exp)

const SPEED = 300.0

# Player stats
var health = 100
var max_health = 100
var experience = 0
var level = 1
var experience_to_next_level = 100

# Weapons and abilities
var weapons = []
var active_weapons = []

# Analog control variables
var analog_velocity = Vector2.ZERO
var using_analog = false

func _ready():
	# Initialize player
	emit_signal("health_changed", health, max_health)
	emit_signal("level_changed", level)
	emit_signal("experience_changed", experience, experience_to_next_level)

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
	# Simple animation logic - can be expanded later
	if velocity.length() > 0:
		# Moving animation
		pass
	else:
		# Idle animation
		pass

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

# Add a weapon
func add_weapon(weapon_scene):
	var weapon = weapon_scene.instance()
	weapons.append(weapon)
	add_child(weapon)

# Upgrade a weapon
func upgrade_weapon(weapon_index):
	if weapon_index < weapons.size():
		weapons[weapon_index].upgrade()
