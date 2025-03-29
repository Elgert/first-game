extends Node2D

# Game settings
var game_time = 60 * 60 # 60 minutes in seconds
var difficulty_curve = 1.0
var current_time = 0
var game_over = false
var score = 0

# Map settings
var map_width = 2000
var map_height = 1500
var map_center = Vector2(0, 0)
var game_bounds = Rect2(-1000, -750, 2000, 1500)

# Enemy settings
var enemy_max_count = 100
var enemy_spawn_distance = 600
var enemy_types = []

# References
@onready var player = $Player
@onready var enemy_spawn_timer = $EnemySpawnTimer
@onready var time_label = $TimeLabel
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var health_label = $CanvasLayer/HUD/HealthBar/HealthLabel
@onready var level_label = $CanvasLayer/HUD/LevelLabel
@onready var exp_bar = $CanvasLayer/HUD/ExpBar

func _ready():
	# Initialize the game
	randomize()

	# Setup HUD
	health_bar.max_value = player.max_health
	health_bar.value = player.health

	# Connect player signals
	player.connect("health_changed", _on_player_health_changed)
	player.connect("level_changed", _on_player_level_changed)
	player.connect("experience_changed", _on_player_experience_changed)

	# Initialize enemy types
	enemy_types.append(preload("res://scenes/enemy_basic.tscn"))

func _process(delta):
	# Update game time
	if !game_over:
		current_time += delta
		_update_time_display()

		# Update difficulty based on time
		difficulty_curve = 1.0 + (current_time / 60.0) * 0.1 # 10% increase per minute

func _update_time_display():
	var time_left = max(game_time - current_time, 0)
	var minutes = floor(time_left / 60)
	var seconds = int(time_left) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]

func _on_enemy_spawn_timer_timeout():
	if game_over:
		return

	# Don't spawn too many enemies
	var enemy_count = get_tree().get_nodes_in_group("enemies").size()
	if enemy_count >= enemy_max_count:
		return

	# Spawn enemies around the player
	var spawn_count = int(2 + difficulty_curve / 2) # More enemies as game progresses
	for i in range(spawn_count):
		_spawn_enemy()

	# Adjust spawn rate based on difficulty
	enemy_spawn_timer.wait_time = max(0.5, 2.0 - (difficulty_curve * 0.1))

func _spawn_enemy():
	# Calculate spawn position around player but within game bounds
	var spawn_pos = Vector2.ZERO
	var tries = 0
	var max_tries = 10

	while tries < max_tries:
		# Try to find a valid spawn position
		var angle = randf() * 2 * PI
		var distance = enemy_spawn_distance + randf() * 200 # Add some randomness
		var potential_pos = player.global_position + Vector2(cos(angle), sin(angle)) * distance

		# Check if within game bounds
		if game_bounds.has_point(potential_pos):
			spawn_pos = potential_pos
			break

		tries += 1

	# If we couldn't find a valid position after max tries, use a position at the edge
	if tries >= max_tries:
		var edge_angle = randf() * 2 * PI
		var edge_x = clamp(player.global_position.x + cos(edge_angle) * enemy_spawn_distance,
						   game_bounds.position.x + 50,
						   game_bounds.position.x + game_bounds.size.x - 50)
		var edge_y = clamp(player.global_position.y + sin(edge_angle) * enemy_spawn_distance,
						   game_bounds.position.y + 50,
						   game_bounds.position.y + game_bounds.size.y - 50)
		spawn_pos = Vector2(edge_x, edge_y)

	# Select random enemy type
	var enemy_scene = enemy_types[randi() % enemy_types.size()]
	var enemy = enemy_scene.instantiate()

	# Set position and add to scene
	enemy.global_position = spawn_pos
	add_child(enemy)

	# Connect signals
	enemy.connect("enemy_died", _on_enemy_died)

	# Scale enemy stats based on difficulty
	enemy.health *= difficulty_curve
	enemy.damage *= difficulty_curve
	enemy.experience_value = int(enemy.experience_value * (1 + difficulty_curve * 0.1))

func _on_enemy_died(position, experience_value):
	# Add experience to player
	player.add_experience(experience_value)

	# Increase score
	score += experience_value * 10

func _on_player_health_changed(new_health, max_health):
	health_bar.value = new_health
	health_bar.max_value = max_health
	health_label.text = "HP: %d/%d" % [new_health, max_health]

	if new_health <= 0 and !game_over:
		_game_over(false) # Player died

func _on_player_level_changed(new_level):
	level_label.text = "Level: %d" % new_level

	# Show level up UI and pause the game
	# This would be implemented later
	pass

func _on_player_experience_changed(new_exp, next_level_exp):
	exp_bar.value = float(new_exp) / next_level_exp

func _on_timer_timeout():
	_game_over(true) # Time's up

func _game_over(victory):
	game_over = true
	enemy_spawn_timer.stop()

	# Show appropriate game over screen
	if victory:
		print("Victory! Final score: %d" % score)
	else:
		print("Game Over! Final score: %d" % score)

	# Disable player movement
	player.set_physics_process(false)
