extends Node

# Enum for weapon/power types
enum WeaponType {
	PROJECTILE,
	ORBIT_FIREBALL,
	FIRE_THUNDER,
	FIRE_TORNADO
}

# Dictionary of all available weapons with their properties
var available_weapons = {
	WeaponType.PROJECTILE: {
		"name": "Magic Projectile",
		"description": "Fires magical projectiles at enemies",
		"icon": "res://assets/sprites/fireball.png",
		"scene": "res://scenes/weapons/weapon_projectile.tscn",
		"script": "res://scripts/weapon_projectile.gd",
		"base_stats": {
			"damage": 10,
			"attack_speed": 1.0,
			"attack_range": 500.0,
			"projectile_count": 1,
			"projectile_speed": 300.0,
			"projectile_spread": 15.0,
			"pierce_count": 0
		},
		"max_level": 8,
		"upgrades": [
			# Level 2
			{
				"description": "Add an extra projectile",
				"stats": {
					"damage": 1.2,
					"projectile_count": 1,
					"projectile_spread": 20.0
				}
			},
			# Level 3
			{
				"description": "Increase damage",
				"stats": {
					"damage": 1.3
				}
			},
			# Level 4
			{
				"description": "Add piercing capability",
				"stats": {
					"pierce_count": 1,
					"projectile_spread": 25.0
				}
			},
			# Level 5
			{
				"description": "Add another projectile",
				"stats": {
					"projectile_count": 1,
					"projectile_spread": 30.0
				}
			},
			# Level 6
			{
				"description": "More piercing",
				"stats": {
					"pierce_count": 1
				}
			},
			# Level 7
			{
				"description": "More damage",
				"stats": {
					"damage": 1.4
				}
			},
			# Level 8
			{
				"description": "Final upgrade - lots of projectiles",
				"stats": {
					"projectile_count": 2,
					"pierce_count": 1,
					"projectile_spread": 40.0
				}
			}
		]
	},

	WeaponType.ORBIT_FIREBALL: {
		"name": "Orbit Fireballs",
		"description": "Fireballs orbit around you, damaging enemies they touch",
		"icon": "res://assets/sprites/fireball.png",
		"scene": "res://scenes/weapons/weapon_orbit.tscn",
		"script": "res://scripts/weapon_orbit.gd",
		"base_stats": {
			"damage": 15,
			"orbit_speed": 0.6,
			"orbit_distance": 100.0,
			"fireball_count": 1,
		},
		"max_level": 5,
		"upgrades": [
			# Level 2
			{
				"description": "Add another fireball",
				"stats": {
					"fireball_count": 2,
					"damage": 1.2
				}
			},
			# Level 3
			{
				"description": "Increase damage and speed",
				"stats": {
					"damage": 1.3,
					"orbit_speed": 1.2
				}
			},
			# Level 4
			{
				"description": "Add another fireball",
				"stats": {
					"fireball_count": 3,
					"damage": 1.2
				}
			},
			# Level 5
			{
				"description": "Max level - add 2 more fireballs and increase damage",
				"stats": {
					"fireball_count": 5,
					"damage": 1.5,
					"orbit_speed": 1.2
				}
			}
		]
	},

	WeaponType.FIRE_THUNDER: {
		"name": "Fire Thunder",
		"description": "Summons lightning strikes from the sky to hit random enemies",
		"icon": "res://assets/sprites/fire_thunder.png",
		"scene": "res://scenes/weapons/weapon_fire_thunder.tscn",
		"script": "res://scripts/weapon_fire_thunder.gd",
		"base_stats": {
			"damage": 30,
			"attack_interval": 5.0, # Every 5 seconds
			"attack_range": 600.0,
			"strike_count": 1
		},
		"max_level": 5,
		"upgrades": [
			# Level 2
			{
				"description": "Increase damage",
				"stats": {
					"damage": 1.5,
				}
			},
			# Level 3
			{
				"description": "Faster strikes",
				"stats": {
					"attack_interval": 0.8, # 20% faster (multiply by 0.8)
				}
			},
			# Level 4
			{
				"description": "Add an extra strike",
				"stats": {
					"strike_count": 1,
					"damage": 1.2
				}
			},
			# Level 5
			{
				"description": "Maximum power: more strikes and damage",
				"stats": {
					"strike_count": 1,
					"damage": 1.5,
					"attack_interval": 0.7 # 30% faster than original
				}
			}
		]
	},

	WeaponType.FIRE_TORNADO: {
		"name": "Fire Tornado",
		"description": "Summons fire tornadoes that travel in wavy paths, damaging enemies",
		"icon": "res://assets/sprites/fire_tornado.png",
		"scene": "res://scenes/weapons/weapon_fire_tornado.tscn",
		"script": "res://scripts/weapon_fire_tornado.gd",
		"base_stats": {
			"damage": 20,
			"attack_interval": 6.0,
			"attack_range": 1000.0,
			"tornado_count": 1,
			"tornado_speed": 150.0
		},
		"max_level": 5,
		"upgrades": [
			# Level 2
			{
				"description": "Increase damage and reduce cooldown",
				"stats": {
					"damage": 1.3,
					"attack_interval": 0.8
				}
			},
			# Level 3
			{
				"description": "Add another tornado (120° angle)",
				"stats": {
					"tornado_count": 1,
					"damage": 1.2
				}
			},
			# Level 4
			{
				"description": "Faster cooldown and increased speed",
				"stats": {
					"attack_interval": 0.7,
					"tornado_speed": 1.3
				}
			},
			# Level 5
			{
				"description": "Maximum power: 3 tornadoes with increased damage",
				"stats": {
					"tornado_count": 1,
					"damage": 1.5,
					"attack_interval": 0.7
				}
			}
		]
	}
}

# Returns a list of available upgrade options
# Considers player's existing weapons and their levels
func get_upgrade_options(player, count = 3):
	var options = []
	var player_weapons = player.weapons

	# Create a list of possible upgrades
	var possible_upgrades = []

	# Add upgrades for existing weapons that aren't max level
	for weapon in player_weapons:
		var weapon_type = _get_weapon_type(weapon)
		if weapon_type != null and weapon.level < available_weapons[weapon_type].max_level:
			possible_upgrades.append({
				"type": weapon_type,
				"is_new": false,
				"current_level": weapon.level
			})

	# Add options for new weapons the player doesn't have yet
	for weapon_type in available_weapons.keys():
		var has_weapon = false
		for weapon in player_weapons:
			if _get_weapon_type(weapon) == weapon_type:
				has_weapon = true
				break

		if not has_weapon:
			possible_upgrades.append({
				"type": weapon_type,
				"is_new": true,
				"current_level": 0
			})

	# Randomize the possible upgrades
	possible_upgrades.shuffle()

	# Select the required number of options, or all if there aren't enough
	var options_count = min(count, possible_upgrades.size())
	for i in range(options_count):
		var upgrade = possible_upgrades[i]
		var weapon_data = available_weapons[upgrade.type]

		var option = {
			"type": upgrade.type,
			"is_new": upgrade.is_new,
			"name": weapon_data.name,
			"description": weapon_data.description,
			"icon": weapon_data.icon
		}

		if not upgrade.is_new:
			var next_level = upgrade.current_level + 1
			var upgrade_data = weapon_data.upgrades[next_level - 2] # -2 because level 2 is index 0
			option.description = upgrade_data.description
		else:
			option.description = "New: " + weapon_data.description

		options.append(option)

	return options

# Apply an upgrade to the player
func apply_upgrade(player, weapon_type):
	var has_weapon = false
	var weapon_to_upgrade = null

	# Check if player already has this weapon
	for weapon in player.weapons:
		if _get_weapon_type(weapon) == weapon_type:
			has_weapon = true
			weapon_to_upgrade = weapon
			break

	if has_weapon:
		# Upgrade existing weapon
		return _upgrade_existing_weapon(weapon_to_upgrade, weapon_type)
	else:
		# Add new weapon
		return _add_new_weapon(player, weapon_type)

# Helper to determine weapon type from an instance
func _get_weapon_type(weapon):
	var weapon_script = weapon.get_script().resource_path

	for type in available_weapons.keys():
		if available_weapons[type].script == weapon_script:
			return type

	return null

# Upgrade an existing weapon
func _upgrade_existing_weapon(weapon, weapon_type):
	var weapon_data = available_weapons[weapon_type]

	if weapon.level >= weapon_data.max_level:
		return false

	# Get the upgrade data for next level
	var next_level = weapon.level + 1
	var upgrade = weapon_data.upgrades[next_level - 2] # -2 because level 2 is index 0

	# Apply the upgrade stats
	weapon.level = next_level

	for stat in upgrade.stats:
		var current_value = weapon.get(stat)
		var multiplier = upgrade.stats[stat]

		# If it's a multiplier (float > 1.0)
		if typeof(multiplier) == TYPE_FLOAT and multiplier > 1.0:
			weapon.set(stat, current_value * multiplier)
		# If it's an additive bonus (int or smaller float)
		else:
			weapon.set(stat, current_value + multiplier)

	# Update derived properties if needed
	if weapon.has_method("_after_upgrade"):
		weapon._after_upgrade()
	elif "attack_speed" in upgrade.stats:
		# Standard cooldown update
		weapon.cooldown = 1.0 / weapon.attack_speed

	return true

# Add a new weapon to the player
func _add_new_weapon(player, weapon_type):
	var weapon_data = available_weapons[weapon_type]

	# Create the resource script
	var script = load(weapon_data.script)

	# Create a new weapon node
	var weapon = Node2D.new()
	weapon.set_script(script)

	# Initialize base stats
	weapon.level = 1
	for stat in weapon_data.base_stats:
		weapon.set(stat, weapon_data.base_stats[stat])

	# Add to player
	player.add_child(weapon)
	player.weapons.append(weapon)

	return true
