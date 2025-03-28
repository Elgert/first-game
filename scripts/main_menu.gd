extends Control

func _ready():
	# Center buttons if needed
	pass

func _on_start_button_pressed():
	# Start the game by loading the game scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()
