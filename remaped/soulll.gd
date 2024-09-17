extends Area

export  var soul = true
var gib = preload("res://Entities/Physics_Objects/Chest_Gib.tscn")

func _ready():
	pass

func player_use():
	if soul:
		Global.set_soul()
	else :
		Global.set_hope()
		Global.player.suicide()
	Global.save_game()
	get_parent().get_node("MeshInstance").hide()
	if not soul:
		for i in range(10):
			var new_gib = gib.instance()
			new_gib.set_name(new_gib.name + "#" + str(new_gib.get_instance_id()))
			get_parent().get_parent().add_child(new_gib)
			new_gib.global_transform.origin = global_transform.origin
			new_gib.damage(20, Vector3.FORWARD.rotated(Vector3.UP, rand_range( - PI, PI)), global_transform.origin, global_transform.origin)
			rpc("spawn_gib", get_parent().get_parent().get_path(), new_gib.name)
		get_parent().get_node("AudioStreamPlayer3D").play()
		queue_free()
		return 
	get_parent().get_node("Particles").emitting = true
	get_parent().get_node("AudioStreamPlayer3D").play()
	queue_free()

master func spawn_gib(recivedPath, recivedName):
	var new_gib = gib.instance()
	get_node(recivedPath).add_child(new_gib)
	new_gib.set_name(recivedName)
