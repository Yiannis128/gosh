class_name BasePawn
extends CharacterBody3D

@export_node_path(Camera3D)
var camera_path : NodePath = ""

var camera : Camera3D = null:
	get:
		return get_node(camera_path)

var player : Player = null

var is_possessed : bool:
	get:
		return player != null

func _ready() -> void:
	pass

func set_camera_active(value : bool):
	assert(camera != null)
	camera.current = value

func get_forward_vector() -> Vector3:
	return -camera.get_global_transform().basis.z

func get_move_forward_vector() -> Vector3:
	return -get_global_transform().basis.z

func get_right_vector() -> Vector3:
	return camera.get_global_transform().basis.x

