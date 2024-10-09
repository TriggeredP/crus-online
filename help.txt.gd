extends Node # extends my balls

# Desine sperare qui hic intras

var frustration_count = 289

var objectInstance

func sync_object_spawn(objectParent):
	var object = objectInstance.instance()
	object.set_name(object.name + "#" + str(object.get_instance_id()))
	objectParent.add_child(object)
	rpc("_spawn_object", objectParent.get_path(), object.name, object.global_transform)

puppet func _spawn_object(parentPath, recivedName, recivedTransform):
	var object = objectInstance.instance()
	object.set_name(recivedName)
	get_node(parentPath).add_child(object)
	object.global_transform = recivedTransform

# AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

# 9 + 10 = 21
# ^ you are stupid
