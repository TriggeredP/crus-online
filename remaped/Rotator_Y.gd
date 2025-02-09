extends KinematicBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

export  var rotation_speed:float = 1

func _ready():
	rset_config("global_transform", MultiplayerAPI.RPC_MODE_PUPPET)
	rotation.y += rand_range(0, TAU)
	
func _physics_process(delta):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		NetworkBridge.n_rset_unreliable(self, "global_transform", [global_transform])
		rotation.y -= rotation_speed * delta
