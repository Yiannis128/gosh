extends Node

@onready var command_line : Control = null

func _init():
	var node = Node.new()
	node.name = "Players"
	add_child(node)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	command_line = preload("res://ui/CommandLine.tscn").instantiate()
	command_line.visible = false
	add_child(command_line)

@remotesync func change_scene(url : String) -> void:
	print("Changing scene to: " + url)
	get_tree().change_scene(url)

func exit_game():
	NetworkManager.disconnect()
	
func _input(event):
	if event is InputEventKey:
		var key_event : InputEventKey = event
		
		if key_event.is_action_pressed("ui_show_cmd"):
			command_line.visible = !command_line.visible
