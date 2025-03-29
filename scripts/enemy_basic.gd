extends CharacterBody2D

signal enemy_died(position, experience_value)

@export var movement_speed = 100.0
@export var health = 10
@export var damage = 5
@export var experience_value = 1

var target = null
var knockback_velocity = Vector2.ZERO
var knockback_resistance = 0.8
var is_dying = false

@onready var player_detection = $PlayerDetection
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	add_to_group("enemies")
	# Find player as target
	target = get_tree().get_first_node_in_group("player")

	# Start walk animation
	animated_sprite.play("walk")

func _physics_process(delta):
	if is_dying:
		return

	if target == null:
		# Try to find player again if lost
		target = get_tree().get_first_node_in_group("player")
		return

	# Apply knockback and reduce it over time
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_resistance)
		velocity = knockback_velocity
	else:
		# Move towards player
		var direction = global_position.direction_to(target.global_position)
		velocity = direction * movement_speed

		# Flip sprite based on movement direction
		if velocity.x < 0:
			animated_sprite.flip_h = true # Moving left, flip sprite
		elif velocity.x > 0:
			animated_sprite.flip_h = false # Moving right, normal sprite

	move_and_slide()

	# Check for collision with player
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider.is_in_group("player"):
			_attack_player(collider)

func _attack_player(player):
	player.take_damage(damage)
	# Apply small knockback to self
	var direction = global_position.direction_to(player.global_position)
	apply_knockback(-direction * 100)

func take_damage(amount, knockback_force = Vector2.ZERO):
	health -= amount

	# Apply knockback
	if knockback_force != Vector2.ZERO:
		apply_knockback(knockback_force)

	if health <= 0:
		die()
	else:
		# Play hit animation/effect - flash the sprite
		modulate = Color(1, 0.5, 0.5) # Red tint
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1) # Back to normal

func apply_knockback(force):
	knockback_velocity = force

func die():
	# Prevent further movement and physics
	is_dying = true
	set_physics_process(false)

	# Play death animation
	animated_sprite.play("die")

	# Wait for animation to finish
	await animated_sprite.animation_finished

	# Emit signal for experience drop
	emit_signal("enemy_died", global_position, experience_value)

	# Remove the enemy
	queue_free()
