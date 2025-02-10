extends KinematicBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

export  var rotation_speed:float = 1

func _ready():
	NetworkBridge.register_rpcs(self, [
		["network_set_rotation", NetworkBridge.PERMISSION.SERVER]
	])

	rotation.y += rand_range(0, TAU)
	
func _physics_process(delta):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		NetworkBridge.n_rpc_unreliable(self, "network_set_rotation", [rotation.y])
		rotation.y -= rotation_speed * delta

puppet func network_set_rotation(id, recived_y):
	rotation.y = recived_y
