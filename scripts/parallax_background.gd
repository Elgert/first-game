extends ParallaxBackground

# How fast the background scrolls relative to the player
@export var scroll_speed = 0.3
@export var follow_player = true

# Reference to the player
var player

func _ready():
	# Find the player in the scene
	player = get_node("/root/Game/Player")

func _process(delta):
	if player and follow_player:
		# Get player's movement and apply it to the background
		var player_velocity = player.velocity

		# Move the background in the opposite direction of player movement
		# This creates the effect of the background moving with the player
		scroll_offset += player_velocity * scroll_speed * delta * -1
