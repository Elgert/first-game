extends Control

signal upgrade_selected(option)

# Load weapon manager
const WeaponManager = preload("res://scripts/weapon_manager.gd")

# Game state before UI was shown
var previous_pause_state = false
var weapon_manager = null
var upgrade_options = []

func _ready():
	# Make sure UI is hidden at start
	hide()

	# Set process mode to stop the game when UI is active
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	# Initialize weapon manager
	weapon_manager = WeaponManager.new()

func show_upgrades():
	# Store current pause state
	previous_pause_state = get_tree().paused

	# Get player reference
	var player = get_tree().get_first_node_in_group("player")

	if player:
		# Get random upgrade options
		upgrade_options = weapon_manager.get_upgrade_options(player, 3)
		_update_option_ui(upgrade_options)

		# Show UI and pause game
		show()
		get_tree().paused = true
	else:
		print("Error: Player not found!")

func _update_option_ui(options):
	var option_containers = [
		$CenterContainer/PanelContainer/VBoxContainer/UpgradeOptions/Option1,
		$CenterContainer/PanelContainer/VBoxContainer/UpgradeOptions/Option2,
		$CenterContainer/PanelContainer/VBoxContainer/UpgradeOptions/Option3
	]

	# Configure each option
	for i in range(min(options.size(), option_containers.size())):
		var option = options[i]
		var container = option_containers[i]
		var label = container.get_node("HBoxContainer/Label")
		var icon = container.get_node("HBoxContainer/MarginContainer/TextureRect")

		# Set the label text
		label.text = option.name + ": " + option.description

		# Load icon if available
		if ResourceLoader.exists(option.icon):
			icon.texture = load(option.icon)

		# Make sure the button is visible
		container.visible = true

	# Hide any unused options
	for i in range(options.size(), option_containers.size()):
		option_containers[i].visible = false

func _close_ui():
	# Hide UI and restore previous pause state
	hide()
	get_tree().paused = previous_pause_state

func _on_option_1_pressed():
	if upgrade_options.size() >= 1:
		_apply_upgrade(0)

func _on_option_2_pressed():
	if upgrade_options.size() >= 2:
		_apply_upgrade(1)

func _on_option_3_pressed():
	if upgrade_options.size() >= 3:
		_apply_upgrade(2)

func _apply_upgrade(option_index):
	var player = get_tree().get_first_node_in_group("player")
	if player and option_index < upgrade_options.size():
		var selected_type = upgrade_options[option_index].type
		weapon_manager.apply_upgrade(player, selected_type)
		emit_signal("upgrade_selected", selected_type)

	_close_ui()
