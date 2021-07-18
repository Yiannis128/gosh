extends Camera3D

@export_node_path(Node3D)
var camera_yaw_path : NodePath = ""
var camera_yaw : Node3D = null:
	get:
		return get_node(camera_yaw_path)

const CAMERA_TURN_RATE : float = 0.005
const MIN_ROT_X : float = -1.5
const MAX_ROT_X : float = 1.5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

@master func _input(event):
	if event is InputEventMouseMotion:
		var mouse_event : InputEventMouseMotion = event
		
		var move : Vector2 = mouse_event.relative
		
		# Horizontal
		camera_yaw.rotate_y(-move.x * CAMERA_TURN_RATE)
		
		# Vertical
		rotate_x(-move.y * CAMERA_TURN_RATE)
		
		rotation.x = clamp(rotation.x, MIN_ROT_X, MAX_ROT_X)
