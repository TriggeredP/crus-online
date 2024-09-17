extends Spatial

onready var Multiplayer = Global.get_node("Multiplayer")

func _physics_process(delta):
	if is_network_master():
		rpc_unreliable("test_rpc", [Vector3.ONE, Vector3.ONE, Vector3.ONE])
		Multiplayer.packages_count += 1

puppet func test_rpc(garbage_data):
	pass
