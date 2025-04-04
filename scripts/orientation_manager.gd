extends Node

func _ready():
	# Force portrait orientation on mobile devices
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
		print("Enforcing portrait orientation")

func _process(_delta):
	# Check orientation continuously and force portrait if needed
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		if DisplayServer.screen_get_orientation() != DisplayServer.SCREEN_PORTRAIT:
			DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
