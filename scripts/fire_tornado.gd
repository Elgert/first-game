extends Area2D

# Tornado properties
@export var damage = 20
@export var speed = 100.0 # Reduced for a slower movement
@export var max_distance = 1000.0
@export var spiral_tightness = 0.15 # Controls how tight the spiral is
@export var rotation_speed = 1.0 # Controls how fast the spiral rotates

# Light effect properties
@export var light_pulse_frequency = 5.0 # Pulses per second
@export var light_min_energy = 1.2
@export var light_max_energy = 2.0

# Internal variables
var direction = Vector2.RIGHT
var source = null
var start_position = Vector2.ZERO
var distance_traveled = 0.0
var time_alive = 0.0
var spiral_angle = 0.0
var spiral_distance = 0.0

func _ready():
	# Start the effect
	start_position = global_position

	# Start the animation
	$AnimatedSprite2D.play("default")

	# Add to the group for reference
	add_to_group("player_projectiles")

func _physics_process(delta):
	# Update time alive
	time_alive += delta

	# Update the spiral
	spiral_angle += rotation_speed * delta
	spiral_distance += speed * delta

	# Calculate spiral path
	var spiral_x = start_position.x + (spiral_distance * cos(spiral_angle)) * direction.x
	var spiral_y = start_position.y + (spiral_distance * sin(spiral_angle)) * direction.y

	# Apply spiral effect stronger as it moves out
	var spiral_effect = spiral_distance * spiral_tightness
	var spiral_offset = Vector2(
		cos(spiral_angle) * spiral_effect,
		sin(spiral_angle) * spiral_effect
	)

	# Set position based on spiral movement
	global_position = Vector2(spiral_x, spiral_y) + spiral_offset

	# Update distance traveled
	distance_traveled = spiral_distance

	# Pulse the light
	if has_node("PointLight2D"):
		var pulse = (sin(time_alive * light_pulse_frequency * TAU) + 1) / 2.0
		$PointLight2D.energy = lerp(light_min_energy, light_max_energy, pulse)

	# Check if traveled max distance
	if distance_traveled >= max_distance:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		# Calculate knockback direction
		var knockback = (global_position - start_position).normalized() * 150

		# Apply damage
		body.take_damage(damage, knockback)

		# Don't destroy the tornado, let it keep going
