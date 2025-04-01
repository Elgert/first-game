extends Control

signal analog_motion(input_vector)
signal analog_released

@export var deadzone_size: float = 0.2
@export var max_distance: float = 100.0

var touch_index = -1
var touch_position = Vector2.ZERO
var stick_position = Vector2.ZERO
var last_input_vector = Vector2.ZERO
var return_accel = 20
var current_vector = Vector2.ZERO

@onready var base = $Base
@onready var stick = $Stick

func _ready():
	# Keep the analog stick invisible at all times
	visible = true
	base.modulate.a = 0
	stick.modulate.a = 0

func _process(delta):
	if touch_index != -1:
		last_input_vector = (stick_position - base.position).normalized()
		# Apply deadzone
		if last_input_vector.length() < deadzone_size:
			last_input_vector = Vector2.ZERO
		# Emit the input vector for movement
		emit_signal("analog_motion", last_input_vector)
	elif stick.position != base.position:
		# Return stick to center when released
		stick.position = stick.position.lerp(base.position, return_accel * delta)
		if stick.position.distance_to(base.position) < 1.0:
			stick.position = base.position
			emit_signal("analog_released")

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			# New touch detected
			touch_index = event.index
			touch_position = event.position
			base.position = touch_position
			stick.position = touch_position
			# Keep invisible when touched
		elif !event.pressed and event.index == touch_index:
			# Touch released
			touch_index = -1
			emit_signal("analog_released")

	elif event is InputEventScreenDrag and event.index == touch_index:
		# Touch dragged
		var drag_position = event.position
		stick_position = drag_position

		# Calculate stick movement
		var distance = stick_position.distance_to(base.position)
		if distance > max_distance:
			stick_position = base.position + (stick_position - base.position).normalized() * max_distance

		stick.position = stick_position
