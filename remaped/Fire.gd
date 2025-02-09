extends KinematicBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var velocity = Vector3.ZERO

var f = preload("res://Entities/Bullets/Fire_Child.tscn")
onready var p = $Particles
var wep

puppet func _set_transform(id, recivedTransform, recivedScale):
	global_transform = recivedTransform
	p.scale = recivedScale

puppet func _delete(id):
	queue_free()

puppet func _create_object(id, recivedPath, recivedObject, recivedName, recivedTransform):
	var newObject = load(recivedObject).instance()
	newObject.set_name(recivedName)
	get_node(recivedPath).add_child(newObject)
	newObject.global_transform = recivedTransform

func _ready():
	set_collision_mask_bit(1, 1)

func _physics_process(delta):
	if NetworkBridge.n_is_network_master(self):
		NetworkBridge.n_rpc_unreliable(self, "_set_transform", [global_transform, p.scale])
		
		var col = move_and_collide(velocity * delta)
		if col:
			var body = col.collider
			var new_fire_child = f.instance()
			new_fire_child.set_name("FireChild#" + str(new_fire_child.get_instance_id()))
			
			if body.has_meta("puppet_body"):
				if not body.onFire:
					body.set_fire(true)
					body.add_child(new_fire_child)
					new_fire_child.global_transform.origin = global_transform.origin
					NetworkBridge.n_rpc(self, "_create_object", [body.get_path(), "res://Entities/Bullets/Fire_Child.tscn", new_fire_child.name, new_fire_child.global_transform])
			else:
				if "soul" in body:
					if body.soul.on_fire:
						pass
					else :
						body.soul.on_fire = true
						body.add_child(new_fire_child)
						new_fire_child.scale.y = 2.0
						new_fire_child.global_transform.origin = body.global_transform.origin - Vector3.UP * 0.5
						NetworkBridge.n_rpc(self, "_create_object", [body.get_path(), "res://Entities/Bullets/Fire_Child.tscn", new_fire_child.name, new_fire_child.global_transform])
				elif "random_line" in body:
					if body.get_parent().on_fire:
						pass
					else :
						body.get_parent().on_fire = true
						body.add_child(new_fire_child)
						new_fire_child.scale.y = 2.0
						new_fire_child.global_transform.origin = body.global_transform.origin - Vector3.UP * 0.5
						NetworkBridge.n_rpc(self, "_create_object", [body.get_path(), "res://Entities/Bullets/Fire_Child.tscn", new_fire_child.name, new_fire_child.global_transform])
				else :
					body.add_child(new_fire_child)
					new_fire_child.global_transform.origin = global_transform.origin
					NetworkBridge.n_rpc(self, "_create_object", [body.get_path(), "res://Entities/Bullets/Fire_Child.tscn", new_fire_child.name, new_fire_child.global_transform])
			NetworkBridge.n_rpc(self, "_delete")
			queue_free()
		velocity.y -= 4 * delta
		velocity *= 0.98
		p.scale += Vector3(0.1, 0.1, 0.1)
		if velocity.length() < 6:
			NetworkBridge.n_rpc(self, "_delete")
			queue_free()

func set_water(value):
	if NetworkBridge.n_is_network_master(self):
		NetworkBridge.n_rpc(self, "_delete")
		queue_free()
