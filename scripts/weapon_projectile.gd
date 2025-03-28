extends WeaponBase

@export var projectile_speed = 300.0
@export var projectile_count = 1
@export var projectile_spread = 15.0 # Degrees between projectiles
@export var pierce_count = 0 # How many enemies a projectile can pierce (0 = no piercing)

var projectile_scene = preload("res://scenes/projectile.tscn")

func _ready():
	super._ready()
	weapon_name = "Projectile Weapon"

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
	projectile.source = owner_node # The player

	# Set position and direction
	projectile.global_position = global_position
	projectile.direction = Vector2(cos(angle), sin(angle))

	# Add to the scene
	get_tree().root.add_child(projectile)

func _apply_upgrade():
	super._apply_upgrade()

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
