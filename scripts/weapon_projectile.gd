extends Node2D

# Weapon properties
@export var weapon_name = "Projectile Weapon"
@export var damage = 10
@export var attack_speed = 1.0  # Attacks per second
@export var attack_range = 500.0
@export var level = 1
@export var max_level = 8

# Projectile specific properties
@export var projectile_speed = 300.0
@export var projectile_count = 1
@export var projectile_spread = 15.0  # Degrees between projectiles
@export var pierce_count = 0  # How many enemies a projectile can pierce (0 = no piercing)

# Internal variables
var cooldown_timer = 0.0
var cooldown = 1.0  # Will be set based on attack_speed

var projectile_scene = preload("res://scenes/projectile.tscn")

func _ready():
	# Initialize weapon
	cooldown = 1.0 / attack_speed

func _physics_process(delta):
	# Handle cooldown
	cooldown_timer -= delta

	# Check if can attack
	if cooldown_timer <= 0:
		# Find targets and attack
		attack()

		# Reset cooldown
		cooldown_timer = cooldown

func attack():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		return

	# Calculate base angle for projectile(s)
	var base_angle = 0
	var enemy = find_target()

	if enemy:
		# Direction to enemy
		base_angle = global_position.angle_to_point(enemy.global_position)
	else:
		# Random direction if no visible enemies
		base_angle = randf() * 2 * PI

	# Fire projectiles in spread pattern
	for i in range(projectile_count):
		var angle_offset = 0
		if projectile_count > 1:
			angle_offset = (i - (projectile_count - 1) / 2.0) * deg_to_rad(projectile_spread)

		var angle = base_angle + angle_offset
		_spawn_projectile(angle)

func _spawn_projectile(angle):
	var projectile = projectile_scene.instantiate()

	# Set projectile properties
	projectile.damage = damage
	projectile.speed = projectile_speed
	projectile.pierce_count = pierce_count
	projectile.source = get_parent()  # The player

	# Set position and direction
	projectile.global_position = global_position
	projectile.direction = Vector2(cos(angle), sin(angle))

	# Add to the scene
	get_tree().root.add_child(projectile)

# Find nearest enemy within range
func find_target():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_enemy = null
	var closest_distance = attack_range

	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_enemy = enemy
			closest_distance = distance

	return closest_enemy

# Level up the weapon
func upgrade():
	if level < max_level:
		level += 1
		_apply_upgrade()
		return true
	return false

# Apply stat upgrades based on level
func _apply_upgrade():
	# Base implementation
	damage = int(damage * 1.2)  # 20% damage increase per level
	attack_speed *= 1.1  # 10% attack speed increase per level
	attack_range *= 1.05  # 5% range increase per level

	# Update cooldown based on new attack speed
	cooldown = 1.0 / attack_speed

	# Specific upgrades for projectile weapon
	match level:
		2:
			# Level 2: Add an extra projectile
			projectile_count += 1
		3:
			# Level 3: Increase damage more
			damage = int(damage * 1.3)
		4:
			# Level 4: Add piercing
			pierce_count += 1
		5:
			# Level 5: Add another projectile
			projectile_count += 1
		6:
			# Level 6: More piercing
			pierce_count += 1
		7:
			# Level 7: More damage
			damage = int(damage * 1.4)
		8:
			# Level 8: Final upgrade - lots of projectiles
			projectile_count += 2
			pierce_count += 1
