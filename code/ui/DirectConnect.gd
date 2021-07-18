extends Node

@export_node_path(LineEdit)
var ip_tb_path : NodePath = ""

@export_node_path(LineEdit)
var port_tb_path : NodePath = ""

@export_node_path(Button)
var host_button_path : NodePath = ""

@export_node_path(Button)
var connect_button_path : NodePath = ""

@export_node_path(Button)
var back_button_path : NodePath = ""

@export_node_path(Button)
var start_button_path : NodePath = ""

func _ready() -> void:
	get_node(host_button_path).connect("pressed", host_pressed)
	get_node(connect_button_path).connect("pressed", connect_pressed)
	get_node(back_button_path).connect("pressed", back_pressed)
	get_node(start_button_path).connect("pressed", start_pressed)
	
	multiplayer.connect("network_peer_connected", player_connected)

func player_connected(id : int) -> void:
	$VBoxContainer/PlayerList.text += "\n" + "Connected: " + str(id)

func host_pressed() -> void:
	var port_text : String = get_node(port_tb_path).text
	var port : int = port_text.to_int()
	
	NetworkManager.host_game(port, 4)
	
	get_node(host_button_path).disabled = true
	get_node(connect_button_path).disabled = true
	get_node(start_button_path).disabled = false

func connect_pressed() -> void:
	var ip : String = get_node(ip_tb_path).text
	
	var port_text : String = get_node(port_tb_path).text
	var port : int = port_text.to_int()
	
	NetworkManager.connect_game(ip, port)
	
	get_node(host_button_path).disabled = true
	get_node(connect_button_path).disabled = true
	get_node(start_button_path).disabled = true

func back_pressed() -> void:
	get_tree().quit()

func start_pressed() -> void:
	if multiplayer.is_network_server():
		Game.rpc(StringName("change_scene"), "res://scenes/maps/Test_01.tscn")
