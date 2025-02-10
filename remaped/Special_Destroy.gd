extends StaticBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

func _ready():
	NetworkBridge.register_rpcs(self, [
		["remove", NetworkBridge.PERMISSION.SERVER]
	])

puppet func remove(id):
	queue_free()

func special_destroy():
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		queue_free()
		NetworkBridge.n_rpc(self, "remove")
