extends Spatial

onready var ball = preload("res://MOD_CONTENT/CruS Online/BenchmarkBall.tscn")

puppet func _create_object(recivedName, recivedOrigin):
	var newObject = ball.instance()
	newObject.set_name(recivedName)
	$Balls.add_child(newObject)
	
	newObject.global_transform.origin = recivedOrigin

master func spawn_ball(count = 1):
	if is_network_master():
		for i in range(count):
			var newObject = ball.instance()
			newObject.set_name(newObject.name + "#" + str(randi() % 1000000000))
			$Balls.add_child(newObject)
			
			newObject.global_transform.origin += Vector3(rand_range(-10.0, 10.0), rand_range(-10.0, 10.0), rand_range(-10.0, 10.0))
			
			rpc("_create_object", newObject.name, newObject.global_transform.origin)
	else:
		rpc("spawn_ball", count)
