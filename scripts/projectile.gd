extends Area2D

signal on_hit(target)

var damage = 10
var speed = 300.0
var direction = Vector2.RIGHT
var pierce_count = 0
var enemies_hit = []
var lifetime = 5.0 # Seconds before auto-destruction
var source = null # The entity that fired this projectile (usually the player)

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Start the lifetime timer
	$Lifetime.wait_time = lifetime
	$Lifetime.start()

	# Start the animation
	animated_sprite.play("default")

	# Set initial rotation based on direction
	_update_rotation()

func _physics_process(delta):
	# Move the projectile
	position += direction * speed * delta

	# Update rotation based on direction
	_update_rotation()

func _update_rotation():
	# Make the fireball face its movement direction
	rotation = direction.angle()

func _on_body_entered(body):
	if body.is_in_group("enemies") and body not in enemies_hit:
		# Deal damage to the enemy
		if body.has_method("take_damage"):
			# Calculate knockback direction based on projectile direction
			var knockback = direction.normalized() * 200
			body.take_damage(damage, knockback)

		# Emit the hit signal
		emit_signal("on_hit", body)

		# Track this enemy as hit
		enemies_hit.append(body)

		# Handle piercing
		if pierce_count <= 0 or enemies_hit.size() > pierce_count:
			queue_free()
		else:
			# Pierced enemy, continue flying
			pass

func _on_lifetime_timeout():
	# Auto-destroy when lifetime expires
	queue_free()
