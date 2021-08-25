class_name BaseGameMode
extends Node

# BaseGameMode class is assigned onto a GameMode node and placed in a level.
# only one GameMode should exist in a level.
# The task of a game mode is to assign players to pawns and direct the rules
# of a level.
# For example, in a death match game mode, the game mode spawns players in
# random spawn points while counting down using an internal clock and once
# the time runs out, ends the game.

@export_file(BasePawn)
var pawn_url : String = ""

var pawn_resource : Resource = null

@export_node_path(Node)
var player_spawn_list_node_path : NodePath = ""
var player_spawn_list : Node:
	get:
		return get_node(player_spawn_list_node_path)

# Done preconfiguring player ids: This is used in initialization.
var done_pc_pid : Array[int] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	randomize()
	
	pawn_resource = load(pawn_url)
	
	if !NetworkManager.is_connected:
		NetworkManager.host_game(6007, 1)
		print("WARNING: CREATED DUMMY SERVER FOR TESTING.")
	
	pre_configure_game()
	
func pre_configure_game():
	print("Pre configure game")
	
	# Pause the world so everything can sync.
	get_tree().set_pause(true)

	# Load players
	var ids : Array[int] = NetworkManager.player_info.keys()
	ids.sort()
	
	for id in ids:
		spawn_player(id)

	# Tell server (remember, server is always ID=1) that this peer is done 
	# pre-configuring. The server can call get_tree().get_rpc_sender_id() 
	# to find out who said they were done.
	if multiplayer.is_network_server():
		done_pc_pid.append(multiplayer.get_network_unique_id())
	
	return
	
	# If host is alone then proceed to post config game.
	if done_pc_pid.size() == NetworkManager.player_info.size():
		rpc(StringName("post_configure_game"))
	else:
		rpc_id(1, StringName("done_preconfiguring"))

# This function is called only if you are the server.
# When the server gets the OK from all the peers, it can tell them to start.
@rpc("any", "nosync", "reliable") func done_preconfiguring():
	var sender_id : int = multiplayer.get_rpc_sender_id()
	
	print("Player ID: " + str(sender_id) + " done preconfiguring")
	
	# Here are some checks you can do, for example
	assert(multiplayer.is_network_server())
	assert(NetworkManager.player_info.has(sender_id)) # Exists
	assert(not sender_id in done_pc_pid) # Was not added yet

	done_pc_pid.append(sender_id)

	# Check if everyone has synced
	if done_pc_pid.size() == NetworkManager.player_info.size():
		rpc(StringName("post_configure_game"))

@rpc("any", "sync", "reliable") func post_configure_game():
	# Only the server is allowed to tell a client to unpause
	if multiplayer.is_network_server():
		print("Preconfiguring finished...")
		get_tree().set_pause(false)

# This function assigns a player to a pawn.
func spawn_player(player_id) -> void:
	# Find all the PlayerSpawn3D nodes and spawn randomly.
	var count : int = player_spawn_list.get_child_count()
	var target_index : int = randi_range(0, count - 1)
	var target : PlayerSpawn3D = player_spawn_list.get_child(target_index)
	
	var pawn : BasePawn = pawn_resource.instantiate()
	pawn.set_name(str(player_id))
	pawn.set_network_master(player_id)
	
	add_child(pawn)
	
	# Set the position
	pawn.global_transform.origin = target.global_transform.origin
	
	var player : Player = NetworkManager.player_info[player_id]
	player.possess_pawn(pawn)
	
	print("Spawned pawn and possessed by: " + str(player.id) + " - " + String(player.name))

# This function is ran when the game starts, it spawns pawns in the level
# in the level and assigns pawns to them.
func on_game_start() -> void:
	pass

