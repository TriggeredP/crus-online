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

func _ready():
	NetworkBridge.register_rpcs(self, [
		["network_use", NetworkBridge.PERMISSION.ALL]
	])
	
	rset_config("global_transform", MultiplayerAPI.RPC_MODE_PUPPET)
	NetworkBridge.register_rset(self, "global_transform", NetworkBridge.PERMISSION.SERVER)
	
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

func _physics_process(delta):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		NetworkBridge.n_rset_unreliable(self, "global_transform", global_transform)
		
		if not open and not stop:
			if not audio_player.playing:
				audio_player.play()
			translation.y += speed * delta
			movement_counter += speed * delta
		if open and not stop:
			if not audio_player.playing:
				audio_player.play()
			translation.y -= speed * delta
			movement_counter += speed * delta
		if movement_counter > mesh_instance.get_aabb().size.y + 0.1:
			audio_player.stop()
			movement_counter = 0
			stop = true

func switch_use():
	if stop and not open:
		open = not open
		stop = not stop

func timeout():
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		stop = not stop
		open = not open

func use():
	network_use(null)

master func network_use(id):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		if stop and not open:
			open = not open
			stop = not stop
			timer.start()
	else:
		NetworkBridge.n_rpc(self, "network_use")
