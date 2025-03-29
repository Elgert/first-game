extends Node2D

# Weapon properties
@export var weapon_name = "Projectile Weapon"
@export var damage = 10
@export var attack_speed = 1 # Attacks per second
@export var attack_range = 500.0
@export var level = 1
@export var max_level = 8

# Projectile specific properties
@export var projectile_speed = 300.0
@export var projectile_count = 1
@export var projectile_spread = 15.0 # Degrees of maximum spread from center
@export var pierce_count = 0 # How many enemies a projectile can pierce (0 = no piercing)

# Internal variables
var cooldown_timer = 0.0
var cooldown = 1.0 # Will be set based on attack_speed
var is_firing = false
var projectiles_to_fire = 0
var base_firing_angle = 0
var fire_delay_timer = 0.0
var fire_delay_min = 0.02 # Minimum delay between shots in seconds
var fire_delay_max = 0.08 # Maximum delay between shots in seconds

var projectile_scene = preload("res://scenes/projectile.tscn")

func _ready():
	# Initialize weapon
	cooldown = 1.0 / attack_speed

func _physics_process(delta):
	# Handle cooldown
	if !is_firing:
		cooldown_timer -= delta

		# Check if can attack
		if cooldown_timer <= 0:
			# Start attack sequence
			start_attack()
	else:
		# Currently in firing sequence
		fire_delay_timer -= delta

		if fire_delay_timer <= 0 and projectiles_to_fire > 0:
			# Fire next projectile
			fire_single_projectile()
			projectiles_to_fire -= 1

			if projectiles_to_fire > 0:
				# Set random delay for next projectile
				fire_delay_timer = randf_range(fire_delay_min, fire_delay_max)
			else:
				# Finished firing sequence
				is_firing = false
				# Reset cooldown
				cooldown_timer = cooldown

func start_attack():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		cooldown_timer = cooldown
		return

	# Calculate base angle for projectile(s)
	var enemy = find_target()

	if enemy:
		# Direction to enemy
		base_firing_angle = global_position.angle_to_point(enemy.global_position)
	else:
		# Random direction if no visible enemies
		base_firing_angle = randf() * 2 * PI

	# Start firing sequence
	is_firing = true
	projectiles_to_fire = projectile_count
	fire_delay_timer = 0 # Fire first projectile immediately

func fire_single_projectile():
	var angle = base_firing_angle

	# For multiple projectiles, add random spread within limits
	if projectile_count > 1:
		# Calculate a random angle within the spread cone
		var max_spread = deg_to_rad(projectile_spread)
		var random_offset = randf_range(-max_spread, max_spread)
		angle += random_offset

	# Spawn the projectile
	_spawn_projectile(angle)

func _spawn_projectile(angle):
	var projectile = projectile_scene.instantiate()

	# Set projectile properties
	projectile.damage = damage
	projectile.speed = projectile_speed
	projectile.pierce_count = pierce_count
	projectile.source = get_parent() # The player

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
	damage = int(damage * 1.2) # 20% damage increase per level
	attack_speed *= 1.1 # 10% attack speed increase per level
	attack_range *= 1.05 # 5% range increase per level

	# Update cooldown based on new attack speed
	cooldown = 1.0 / attack_speed

	# Specific upgrades for projectile weapon
	match level:
		2:
			# Level 2: Add an extra projectile
			projectile_count += 1
			# Slightly increase spread for multiple projectiles
			projectile_spread = 20.0
		3:
			# Level 3: Increase damage more
			damage = int(damage * 1.3)
		4:
			# Level 4: Add piercing
			pierce_count += 1
			# Increase spread slightly
			projectile_spread = 25.0
		5:
			# Level 5: Add another projectile
			projectile_count += 1
			# Increase spread slightly
			projectile_spread = 30.0
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
			# Final spread adjustment
			projectile_spread = 40.0
