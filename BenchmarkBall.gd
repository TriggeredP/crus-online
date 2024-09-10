extends Spatial

onready var Multiplayer = Global.get_node("Multiplayer")

func _ready():
	Multiplayer.connect("host_tick", self, "host_tick")

func host_tick():
	rpc_unreliable("test_rpc")
	Multiplayer.packages_count += 1

puppet func test_rpc():
	pass
