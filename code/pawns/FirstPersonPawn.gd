extends BasePawn

@export
var max_move_speed : float = 150

@export
var ground_acceleration : float = 300

@export
var gravity_acceleration : Vector3 = Vector3(0, -300, 0)

var move_velocity : Vector3 = Vector3.ZERO

func _ready():
	rpc_config(StringName("sync_transform"),
		MultiplayerAPI.RPC_MODE_PUPPET,
		MultiplayerPeer.TRANSFER_MODE_UNRELIABLE_ORDERED)

func _process(_delta):
	rpc(StringName("sync_transform"), global_transform)

func _physics_process(delta : float) -> void:
	base_move(delta)
	
	# Apply gravity
	linear_velocity += gravity_acceleration * delta
	
	move_and_slide()

func base_move(delta : float) -> void:
	var move_right : float = Input.get_axis("move_left", "move_right")
	var move_forward : float = Input.get_axis("move_back", "move_forward")
	
	var move_right_dir : Vector3 = get_right_vector() * move_right
	var move_forward_dir : Vector3 = get_move_forward_vector() * move_forward
	
	var move_dir : Vector3 = move_right_dir + move_forward_dir
	
	move_velocity = move_dir * max_move_speed * delta
	linear_velocity += 

@rpc("puppet", "nosync", "unreliable")
func sync_transform(_transform : Transform3D):
	global_transform = _transform
