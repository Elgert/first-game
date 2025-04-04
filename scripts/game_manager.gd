extends Node2D

# Game settings
var game_time = 60 * 60 # 60 minutes in seconds
var difficulty_curve = 1.0
var current_time = 0
var game_over = false
var score = 0

# Map settings - now unbounded
var enemy_spawn_distance = 600

# Enemy settings
var enemy_max_count = 100
var enemy_types = []

# Level up UI
var level_up_ui_scene = preload("res://scenes/level_up_ui.tscn")
var level_up_ui = null

# Weapon management
var weapon_manager_script = preload("res://scripts/weapon_manager.gd")
var weapon_manager = null

# References
@onready var player = $Player
@onready var enemy_spawn_timer = $EnemySpawnTimer
@onready var time_label = $CanvasLayer/HUD/TimePanel/TimeLabel
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var health_label = $CanvasLayer/HUD/HealthBar/HealthLabel
@onready var level_label = $CanvasLayer/HUD/BottomPanel/LevelLabel
@onready var exp_bar = $CanvasLayer/HUD/ExpBar
@onready var game_over_overlay = $CanvasLayer/GameOverOverlay
@onready var score_label = $CanvasLayer/GameOverOverlay/Panel/ScoreLabel

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

	# Initialize weapon manager
	weapon_manager = weapon_manager_script.new()

	# Make sure game over overlay is hidden initially
	game_over_overlay.visible = false

func _process(delta):
	# Update game time
	if !game_over:
		current_time += delta
		_update_time_display()

		# Update difficulty based on time
		difficulty_curve = 1.0 + (current_time / 5.0) * 0.5 # 10% increase per minute

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
	enemy_spawn_timer.wait_time = max(0.1, 2.0 - (difficulty_curve * 0.5))

	# Spawn enemies
	for i in range(spawn_count):
		_spawn_enemy()

func _spawn_enemy():
	var enemy_type = enemy_types[0] # Just using the basic enemy for now
	var enemy = enemy_type.instantiate()

	# Get random direction from player
	var angle = randf() * 2 * PI
	var direction = Vector2(cos(angle), sin(angle))
	var spawn_pos = player.global_position + direction * enemy_spawn_distance

	# Set enemy position and connect signals
	enemy.global_position = spawn_pos
	enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))

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

	# Check if there are any upgrades available
	var has_upgrades_available = false

	# Get player weapons
	for weapon in player.weapons:
		if weapon.level < weapon.max_level:
			has_upgrades_available = true
			break

	# Check if any new weapons could be added
	if weapon_manager and player.weapons.size() < weapon_manager.available_weapons.size():
		has_upgrades_available = true

	# Only show level up UI if upgrades are available
	if has_upgrades_available:
		# Show level up UI and pause the game
		level_up_ui.show_upgrades()
	else:
		print("Maximum level reached for all weapons - no upgrades available")

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

	# Disable player movement
	player.set_physics_process(false)

	# Update score on the game over screen
	score_label.text = "Score: %d" % score

	# Show the game over overlay
	game_over_overlay.visible = true

	# Stop any ongoing game processes
	get_tree().paused = true

func _on_return_to_menu_button_pressed():
	# Unpause the game before changing scenes
	get_tree().paused = false

	# Return to the main menu
	get_tree().change_scene_to_file("res://scenes/main.tscn")
