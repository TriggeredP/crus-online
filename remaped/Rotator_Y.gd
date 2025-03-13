extends KinematicBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

export  var rotation_speed:float = 1

func _ready():
	NetworkBridge.register_rpcs(self, [
		["network_set_rotation", NetworkBridge.PERMISSION.SERVER]
	])

	rotation.y += rand_range(0, TAU)
	
var tick = 0

func _physics_process(delta):
	rotation.y -= rotation_speed * delta
	
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		tick += 1
		if tick % 30 == 0:
			NetworkBridge.n_rpc_unreliable(self, "network_set_rotation", [rotation.y])
			tick = 0

puppet func network_set_rotation(id, recived_y):
	rotation.y = recived_y
