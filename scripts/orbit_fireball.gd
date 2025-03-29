extends Area2D

# Fireball properties
@export var damage = 15
@export var orbit_speed = 2.0 # Rotations per second
@export var orbit_distance = 100.0 # Distance from player
@export var orbit_offset = 0.0 # Starting angle offset

# Internal variables
var orbit_angle = 0.0
var parent_node = null

func _ready():
	# Set parent (player) reference
	parent_node = get_parent()

	# Set initial angle with offset
	orbit_angle = orbit_offset

	# Start the animation
	$AnimatedSprite2D.play("default")

func _physics_process(delta):
	if parent_node:
		# Update orbit angle based on speed
		orbit_angle += orbit_speed * delta * TAU # TAU is 2*PI

		# Calculate position based on orbit angle
		var orbit_pos = Vector2(
			cos(orbit_angle) * orbit_distance,
			sin(orbit_angle) * orbit_distance
		)

		# Set position relative to parent
		position = orbit_pos

func _on_body_entered(body):
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		# Calculate knockback direction based on impact
		var knockback = (body.global_position - global_position).normalized() * 150

		# Apply damage and knockback
		body.take_damage(damage, knockback)
