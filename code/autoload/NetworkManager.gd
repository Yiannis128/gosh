extends Node
# https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html
# Player info, associate ID to data
var player_info : Dictionary = {}
# Info we send to other players
var local_player : Player = null

var players_node : Node:
	get:
		return Game.get_node("Players")

var is_connected : bool = false:
	get:
		return multiplayer.has_network_peer()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Create the player.
	local_player = preload("res://game_objects/Player.tscn").instantiate()
	local_player.name = "player_" + str(local_player.get_instance_id())
	
	multiplayer.connect("network_peer_connected", player_connected)
	multiplayer.connect("network_peer_disconnected", player_disconnected)
	multiplayer.connect("connected_to_server", connect_ok)
	multiplayer.connect("connection_failed", connect_failed)
	multiplayer.connect("server_disconnected", server_disconnected)

func is_server() -> bool:
	return multiplayer.is_network_server()

func host_game(port : int = 6007, max_players : int = 4) -> int:
	var network = ENetMultiplayerPeer.new()
	var error : int = network.create_server(port, max_players)
	
	if error != OK:
		printerr("There was a problem while creating a server (" +
			str(error) + ").")
		return error

	multiplayer.set_network_peer(network)
	
	print("Hosting Server (" + str(error) + "): " + str(port))
	print("Max Players: " + str(max_players))
	print("Unique Network ID: " + str(multiplayer.get_network_unique_id()))
	
	# Register ourselves as part of the players.
	# This adds local_player into player_info
	local_player.id = 1
	rpc_id(1, StringName("register_player"), local_player.name)
	
	return error

func connect_game(ip : String, port : int) -> int:
	var network = ENetMultiplayerPeer.new()
	var error : int = network.create_client(ip, port)
	
	if error != OK:
		printerr("There was a problem while trying to connect to the server (" +
			str(error) + ").")
		return error
		
	multiplayer.set_network_peer(network)
	
	print("Connecting to server (" + str(error) + "): " +
		str(ip) + ":" + str(port))
	print("Unique Network ID: " + str(multiplayer.get_network_unique_id()))
	
	return error

func player_connected(_id : int) -> void:
	pass

func player_disconnected(id : int) -> void:
	# Erase player information from record.
	print(str(id) + " - " + String(player_info[id].name) + " has disconnected.")
	player_info.erase(id)

# Make sure to gather info on everyone connected already, and also
# announce the client to the entire network.
func connect_ok() -> void:
	local_player.id = multiplayer.get_network_unique_id()
	
	# Send info to network peers so that they have your information.
	rpc(StringName("register_player"), local_player.name)
	
	# Ask information back from all other peers.
	rpc(StringName("send_info_request"))

func connect_failed() -> void:
	# Could not even connect to server, abort.
	pass

func server_disconnected() -> void:
	player_info.clear()
	local_player.id = 0
	
	for node_index in players_node.get_child_count():
		players_node.remove_child(players_node.get_child(node_index))

func disconnect() -> void:
	get_tree().multiplayer.network_peer = null

# Respond to sender with your information so that they can register you.
@rpc("any", "nosync", "reliable") func send_info_request() -> void:
	var caller_id : int = multiplayer.get_rpc_sender_id()
	rpc_id(caller_id, StringName("register_player"), local_player.name)

@rpc("any", "sync", "reliable") func register_player(_name : String):
	var player : Player = preload("res://game_objects/Player.tscn").instantiate()
	player.id = multiplayer.get_rpc_sender_id()
	player.name = _name
	players_node.add_child(player)
	
	# Score the info.
	player_info[player.id] = player
	
	print("Player Registered: " + str(player.id) + " - " + String(player.name))
