extends Control

func _ready():
	# Center buttons if needed
	pass

func _on_start_button_pressed():
	# Start the game by loading the game scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_choose_level_button_pressed():
	# This will be implemented later
	# For now just show a message
	print("Choose Level button pressed - to be implemented")

	# Create a popup message
	var popup = AcceptDialog.new()
	popup.title = "Coming Soon"
	popup.dialog_text = "Level selection will be available in a future update!"
	popup.position = Vector2(get_viewport_rect().size.x / 2 - 150, get_viewport_rect().size.y / 2 - 50)
	add_child(popup)
	popup.popup_centered()

func _on_upgrade_character_button_pressed():
	# This will be implemented later
	# For now just show a message
	print("Upgrade Character button pressed - to be implemented")

	# Create a popup message
	var popup = AcceptDialog.new()
	popup.title = "Coming Soon"
	popup.dialog_text = "Character upgrades will be available in a future update!"
	popup.position = Vector2(get_viewport_rect().size.x / 2 - 150, get_viewport_rect().size.y / 2 - 50)
	add_child(popup)
	popup.popup_centered()

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()
