class_name Player
extends Node

var id : int = 0;
var pawn : BasePawn = null

func _init():
	pass

func possess_pawn(target : BasePawn):
	# If we are possessing another pawn, depossess that.
	if pawn != null:
		depossess_pawn()
	
	# Check if the pawn is already possessed.
	if target.player != null:
		target.player.depossess_pawn()
	
	pawn = target
	pawn.player = self
	
	if id == multiplayer.get_network_unique_id():
		pawn.set_camera_active(true)
	
func depossess_pawn():
	pawn.player = null
	pawn = null
	
	if id == get_tree().multiplayer.get_network_unique_id():
		pawn.set_camera_active(false)
