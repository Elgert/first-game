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

# Level up UI
var level_up_ui_scene = preload("res://scenes/level_up_ui.tscn")
var level_up_ui = null

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

	# Initialize level up UI
	level_up_ui = level_up_ui_scene.instantiate()
	$CanvasLayer.add_child(level_up_ui)
	level_up_ui.connect("upgrade_selected", _on_upgrade_selected)

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
	# Get current enemy count
	var current_enemies = get_tree().get_nodes_in_group("enemies").size()

	if current_enemies >= enemy_max_count:
		return

	# Calculate number of enemies to spawn based on difficulty
	var spawn_count = int(1 + difficulty_curve / 2)

	# Limit to max
	spawn_count = min(spawn_count, enemy_max_count - current_enemies)

	# Adjust spawn timer based on difficulty
	enemy_spawn_timer.wait_time = max(0.5, 2.0 - (difficulty_curve * 0.1))

	# Spawn enemies
	for i in range(spawn_count):
		_spawn_enemy()

func _spawn_enemy():
	var enemy_type = enemy_types[0] # Just using the basic enemy for now
	var enemy = enemy_type.instantiate()

	# Find a valid spawn position within game bounds
	var valid_position = false
	var spawn_pos = Vector2.ZERO
	var attempts = 0

	while !valid_position and attempts < 10:
		# Get random direction from player
		var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		spawn_pos = player.global_position + direction * enemy_spawn_distance

		# Ensure spawn position is within game bounds
		if game_bounds.has_point(spawn_pos):
			valid_position = true
		else:
			attempts += 1

	# If we couldn't find a valid position, use a position at the edge
	if !valid_position:
		var angle = randf() * 2 * PI
		var direction = Vector2(cos(angle), sin(angle))
		spawn_pos = player.global_position + direction * (enemy_spawn_distance * 0.8)

		# Clamp to game bounds
		spawn_pos.x = clamp(spawn_pos.x, game_bounds.position.x, game_bounds.position.x + game_bounds.size.x)
		spawn_pos.y = clamp(spawn_pos.y, game_bounds.position.y, game_bounds.position.y + game_bounds.size.y)

	# Set enemy position and connect signals
	enemy.global_position = spawn_pos
	enemy.connect("enemy_died", _on_enemy_died)

	# Add to scene
	add_child(enemy)

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
	level_up_ui.show_upgrades()

func _on_player_experience_changed(new_exp, next_level_exp):
	exp_bar.value = float(new_exp) / next_level_exp

func _on_upgrade_selected(option):
	# Apply the selected upgrade to the player
	player.apply_upgrade(option)

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
