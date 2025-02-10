extends Area

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var lifetime = 200
var t = 0
var player_fire = false

onready var f = load("res://Entities/Bullets/Fire_Child.tscn")

func _ready():
	NetworkBridge.register_rpcs(self, [
		["_set_transform", NetworkBridge.PERMISSION.SERVER],
		["_delete", NetworkBridge.PERMISSION.SERVER],
		["_create_object", NetworkBridge.PERMISSION.SERVER]
	])

puppet func _set_transform(id, recivedTransform):
	global_transform = recivedTransform

puppet func _delete(id):
	queue_free()

puppet func _create_object(id, recivedPath, recivedObject, recivedName, recivedTransform, recivedPlayerFire = null):
	var newObject = load(recivedObject).instance()
	newObject.set_name(recivedName)
	get_node(recivedPath).add_child(newObject)
	newObject.global_transform = recivedTransform
	if recivedPlayerFire != null:
		newObject.player_fire = recivedPlayerFire

func _physics_process(delta):
	if NetworkBridge.n_is_network_master(self):
		NetworkBridge.n_rpc_unreliable(self, "_set_transform", [global_transform])
		
		t += 1
		if lifetime < t:
			var parent = get_parent()
			if parent.has_method("set_fire"):
				parent.set_fire(false)
			
			NetworkBridge.n_rpc(self, "_delete")
			queue_free()
		
		if fmod(t, 25) != 0:
			return
		
		var parent = get_parent()
		
		if parent.has_method("player_damage"):
			parent.player_damage(5, Vector3.ZERO, global_transform.origin, global_transform.origin, "fire")
		else:
			if "soul" in parent and not "random_line" in parent:
				if parent.soul.pain_sfx[0].stream != parent.soul.firesound:
					parent.soul.pain_sfx[0].stream = parent.soul.firesound
				parent.soul.damage(20.6, Vector3.ZERO, global_transform.origin, global_transform.origin)
			elif "random_line" in parent:
				if not "pain_sfx" in parent.get_parent():
					return 
				if parent.get_parent().pain_sfx[0].stream != parent.get_parent().firesound:
					parent.get_parent().pain_sfx[0].stream = parent.get_parent().firesound
				parent.get_parent().damage(5, Vector3.ZERO, global_transform.origin, global_transform.origin)
			else:
				if parent.has_method("damage"):
					parent.damage(5, Vector3.ZERO, global_transform.origin, global_transform.origin)

func _on_Area_body_entered(body):
	if NetworkBridge.n_is_network_master(self):
		var parent = get_parent()
		
		if body != parent:
			if body.has_meta("puppet") and not body.has_meta("puppet_body"):
				return
			elif not body.has_meta("puppet_body") and "soul" in body:
				var new_fire_child = f.instance()
				new_fire_child.set_name("FireChild#" + str(new_fire_child.get_instance_id()))
				
				if body.soul.on_fire:
					return 
				body.soul.on_fire = true
				body.soul.body.add_child(new_fire_child)
				new_fire_child.scale.y = 2.0
				new_fire_child.global_transform.origin = body.soul.body.global_transform.origin - Vector3.UP * 0.5
				
				NetworkBridge.n_rpc(self, "_create_object", [body.soul.body.get_path(), "res://Entities/Bullets/Fire_Child.tscn", new_fire_child.name, new_fire_child.global_transform, true])
			elif (body == Global.player or body.has_meta("puppet_body")) and not player_fire:
				var new_fire_child = f.instance()
				new_fire_child.set_name("FireChild#" + str(new_fire_child.get_instance_id()))
				
				body.add_child(new_fire_child)
				player_fire = true
				new_fire_child.player_fire = true
				new_fire_child.scale.y = 2.0
				new_fire_child.global_transform.origin = body.global_transform.origin - Vector3.UP * 0.5
					
				NetworkBridge.n_rpc(self, "_create_object", [body.get_path(), "res://Entities/Bullets/Fire_Child.tscn", new_fire_child.name, new_fire_child.global_transform, true])

func set_water(value):
	if NetworkBridge.n_is_network_master(self):
		NetworkBridge.n_rpc(self, "_delete")
		queue_free()
