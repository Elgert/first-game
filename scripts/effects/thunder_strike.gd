extends Node2D

# Target enemy reference
var target = null
var damage = 30
var knockback_strength = 200.0

# Effect duration
var total_duration = 0.6
var current_time = 0.0

# References
@onready var lightning_sprite = $LightningSprite
@onready var impact_area = $ImpactArea
@onready var light = $PointLight2D
@onready var animation_player = $AnimationPlayer

func _ready():
	# Position at target if available
	if target and is_instance_valid(target):
		global_position = target.global_position

	# Play the animation
	animation_player.play("strike")

func _process(delta):
	# Follow target if it's moving
	if target and is_instance_valid(target):
		global_position = target.global_position

	# Update time and check if effect should end
	current_time += delta
	if current_time >= total_duration:
		queue_free()

# Called when animation triggers the strike moment
func _on_strike_moment():
	# Apply damage to target if still valid
	if target and is_instance_valid(target) and target.has_method("take_damage"):
		var knockback_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		target.take_damage(damage, knockback_direction * knockback_strength)

	# Apply damage to other enemies in impact area
	var bodies = impact_area.get_overlapping_bodies()
	for body in bodies:
		if body != target and body.is_in_group("enemies") and body.has_method("take_damage"):
			var knockback_direction = (body.global_position - global_position).normalized()
			body.take_damage(damage * 0.6, knockback_direction * knockback_strength * 0.5) # Reduced damage for splash
