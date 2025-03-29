extends Control

signal upgrade_selected(option)

# Reference to the orbit weapon class
const WeaponOrbitScript = preload("res://scripts/weapon_orbit.gd")

# Menu option types
enum UpgradeOption {
	PROJECTILE_COUNT,
	FIRING_SPEED,
	ORBIT_FIREBALL
}

# Game state before UI was shown
var previous_pause_state = false

func _ready():
	# Make sure UI is hidden at start
	hide()

	# Set process mode to stop the game when UI is active
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func show_upgrades():
	# Store current pause state
	previous_pause_state = get_tree().paused

	# Set descriptions based on player's current state
	_update_option_descriptions()

	# Show UI and pause game
	show()
	get_tree().paused = true

func _update_option_descriptions():
	var option1_label = $CenterContainer/PanelContainer/VBoxContainer/UpgradeOptions/Option1/HBoxContainer/Label
	var option2_label = $CenterContainer/PanelContainer/VBoxContainer/UpgradeOptions/Option2/HBoxContainer/Label
	var option3_label = $CenterContainer/PanelContainer/VBoxContainer/UpgradeOptions/Option3/HBoxContainer/Label

	# Check if player already has orbit fireballs
	var player = get_tree().get_first_node_in_group("player")
	var has_orbit_weapon = false

	if player:
		for weapon in player.weapons:
			if weapon.get_script() == WeaponOrbitScript:
				has_orbit_weapon = true
				option3_label.text = "Increase Orbiting Fireballs"
				break

	if not has_orbit_weapon:
		option3_label.text = "Add Orbiting Fireballs"

func _on_option_1_pressed():
	# Increase projectile count
	emit_signal("upgrade_selected", UpgradeOption.PROJECTILE_COUNT)
	_close_ui()

func _on_option_2_pressed():
	# Increase firing speed
	emit_signal("upgrade_selected", UpgradeOption.FIRING_SPEED)
	_close_ui()

func _on_option_3_pressed():
	# Add or upgrade orbit fireballs
	emit_signal("upgrade_selected", UpgradeOption.ORBIT_FIREBALL)
	_close_ui()

func _close_ui():
	# Hide UI
	hide()

	# Restore previous pause state
	get_tree().paused = previous_pause_state
