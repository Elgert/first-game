extends ParallaxBackground

# How fast the background scrolls relative to the player
@export var scroll_speed = 0.4
@export var follow_player = true

# Reference to the player
var player
var last_player_position = Vector2.ZERO

func _ready():
	# Find the player in the scene
	player = get_node("/root/Game/Player")
	if player:
		last_player_position = player.global_position

func _process(delta):
	if player and follow_player:
		# Calculate player's movement from last position
		var player_movement = player.global_position - last_player_position

		# Scroll the background in the opposite direction of player movement
		scroll_offset -= player_movement * scroll_speed

		# Update last position for the next frame
		last_player_position = player.global_position
