extends Spatial

onready var ball = preload("res://MOD_CONTENT/CruS Online/BenchmarkBall.tscn")

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

func _ready():
	NetworkBridge.register_rpcs(self,[
		["_create_object", NetworkBridge.PERMISSION.SERVER],
		["spawn_ball", NetworkBridge.PERMISSION.ALL]
	])

puppet func _create_object(id, recivedName, recivedOrigin):
	var newObject = ball.instance()
	newObject.set_name(recivedName)
	$Balls.add_child(newObject)
	
	newObject.global_transform.origin = recivedOrigin

master func spawn_ball(id, count = 1):
	if NetworkBridge.n_is_network_master(self):
		for i in range(count):
			var newObject = ball.instance()
			newObject.set_name(newObject.name + "#" + str(newObject.get_instance_id()))
			$Balls.add_child(newObject)
			
			newObject.global_transform.origin += Vector3(rand_range(-10.0, 10.0), rand_range(-10.0, 10.0), rand_range(-10.0, 10.0))
			
			NetworkBridge.n_rpc(self, "_create_object", [newObject.name, newObject.global_transform.origin])
	else:
		NetworkBridge.n_rpc(self, "spawn_ball", [count])
