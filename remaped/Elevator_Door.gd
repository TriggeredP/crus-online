extends KinematicBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

export  var door_health = 100
export  var speed = 2
var open = false
var stop = true
var initrot = rotation
var movement_counter = 0
var mesh_instance
var collision_shape
var collision = false
var found_overlap
var sfx = preload("res://Sfx/Environment/door_concrete.wav")
var audio_player:AudioStreamPlayer3D
var timer:Timer

var lerp_translation

func _ready():
	NetworkBridge.register_rpcs(self, [
		["set_door", NetworkBridge.PERMISSION.SERVER],
		["network_use", NetworkBridge.PERMISSION.ALL]
	])
	
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 5
	timer.one_shot = true
	timer.connect("timeout", self, "timeout")
	set_collision_layer_bit(8, 1)
	audio_player = AudioStreamPlayer3D.new()
	audio_player.stream = sfx
	add_child(audio_player)
	for child in get_children():
		if child is MeshInstance:
			mesh_instance = child
		if child is CollisionShape:
			collision_shape = child
	var t = mesh_instance.transform
	global_transform.origin.x -= mesh_instance.get_aabb().position.x
	global_transform.origin.z -= mesh_instance.get_aabb().position.z
	t = t.translated(Vector3(mesh_instance.get_aabb().position.x, 0, mesh_instance.get_aabb().position.z))
	mesh_instance.transform = t
	collision_shape.transform = t
	
	lerp_translation = translation

func _physics_process(delta):
	if not open and not stop:
		if not audio_player.playing:
			audio_player.play()
		if mesh_instance.get_aabb().size.x > mesh_instance.get_aabb().size.z:
			translation.x += speed * delta
		elif mesh_instance.get_aabb().size.x < mesh_instance.get_aabb().size.z:
			translation.z += speed * delta
		else :
			translation.z += speed * delta
			translation.x += speed * delta
		movement_counter += speed * delta
	if open and not stop:
		if not audio_player.playing:
			audio_player.play()
		if mesh_instance.get_aabb().size.x > mesh_instance.get_aabb().size.z:
			translation.x -= speed * delta
		elif mesh_instance.get_aabb().size.x < mesh_instance.get_aabb().size.z:
			translation.z -= speed * delta
		else :
			translation.z -= speed * delta
			translation.x -= speed * delta
		movement_counter += speed * delta
	if movement_counter > mesh_instance.get_aabb().size.x + 0.1 and movement_counter > mesh_instance.get_aabb().size.z + 0.1:
		audio_player.stop()
		movement_counter = 0
		stop = true
		if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
			NetworkBridge.n_rpc(self, "set_door", [stop, open, translation])

puppet func set_door(id, recived_stop, recived_open, recived_translation = null):
	stop = recived_stop
	open = recived_open
	
	if recived_translation != null:
		translation = recived_translation

func timeout():
	stop = not stop
	open = not open
	
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		NetworkBridge.n_rpc(self, "set_door", [stop, open, translation])

func use():
	network_use(null)
	
master func network_use(id):
	if NetworkBridge.check_connection():
		if stop and not open:
			open = not open
			stop = not stop
			
			timer.start()
			if NetworkBridge.n_is_network_master(self):
				NetworkBridge.n_rpc(self, "set_door", [stop, open])
			else:
				NetworkBridge.n_rpc(self, "network_use")
