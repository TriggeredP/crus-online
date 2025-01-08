extends Spatial

onready var Multiplayer = Global.get_node("Multiplayer")
onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

func _ready():
	NetworkBridge.register_rpcs(self,[
		["test_rpc", NetworkBridge.PERMISSION.SERVER]
	])

func _physics_process(delta):
	if NetworkBridge.n_is_network_master():
		NetworkBridge.n_rpc_unreliable(self, "test_rpc", [[Vector3.ONE, Vector3.ONE, Vector3.ONE]])

puppet func test_rpc(id, garbage_data):
	pass
