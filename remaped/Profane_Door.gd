extends KinematicBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var PARTICLE = preload("res://Entities/Particles/Destruction_Particle.tscn")

export  var door_health = 100
export  var rotation_speed = 2
var open = false
var stop = true
var initrot = rotation
var rotation_counter = 0
var mesh_instance
var collision_shape
var collision = false
var found_overlap
var type = 1
var audio_player

var isDestroyed = false

func _ready():
	NetworkBridge.register_rpcs(self, [
		["player_use", NetworkBridge.PERMISSION.ALL],
		["door_use", NetworkBridge.PERMISSION.ALL]
	])
	
	rset_config("global_transform",MultiplayerAPI.RPC_MODE_PUPPET)
	
	set_process(false)
	set_collision_layer_bit(8, 1)
	for child in get_children():
		if child is MeshInstance:
			mesh_instance = child
		if child is CollisionShape:
			collision_shape = child
	var t = mesh_instance.transform
	
	if mesh_instance.get_aabb().size.x > mesh_instance.get_aabb().size.z:
		global_transform.origin.x -= mesh_instance.get_aabb().position.x
		global_transform.origin.z -= mesh_instance.get_aabb().position.z + mesh_instance.get_aabb().size.z * 0.5
		t = t.translated(Vector3(mesh_instance.get_aabb().position.x, 0, mesh_instance.get_aabb().position.z + mesh_instance.get_aabb().size.z * 0.5))
	else :
		global_transform.origin.x -= mesh_instance.get_aabb().position.x + mesh_instance.get_aabb().size.x * 0.5
		global_transform.origin.z -= mesh_instance.get_aabb().position.z
		t = t.translated(Vector3(mesh_instance.get_aabb().position.x + mesh_instance.get_aabb().size.x * 0.5, 0, mesh_instance.get_aabb().position.z))
	
	mesh_instance.transform = t
	collision_shape.transform = t

	audio_player = AudioStreamPlayer3D.new()
	get_parent().call_deferred("add_child", audio_player)
	yield (get_tree(), "idle_frame")
	audio_player.global_transform.origin = global_transform.origin
	audio_player.stream = load("res://Sfx/Environment/doorkick.wav")
	audio_player.unit_size = 10
	audio_player.unit_db = 4
	audio_player.max_db = 4
	audio_player.pitch_scale = 0.6

func _physics_process(delta):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		if not open and not stop:
			rotation.y += rotation_speed * delta
			rotation_counter += rad2deg(rotation_speed * delta)
			NetworkBridge.n_rset_unreliable(self, "global_transform", global_transform)
		if open and not stop:
			rotation.y -= rotation_speed * delta
			rotation_counter += rad2deg(rotation_speed * delta)
			NetworkBridge.n_rset_unreliable(self, "global_transform", global_transform)
		if rotation_counter > 90:
			rotation_counter = 0
			stop = true

func get_type():
	return type;

master func player_use(id):
	if Global.husk_mode:
		if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
			door_use(null)
		else:
			NetworkBridge.n_rpc(self, "door_use")
	else:
		Global.player.UI.notify("It repulses you.", Color(0.5, 0.5, 0))
		Global.player.player_velocity -= (global_transform.origin - Global.player.global_transform.origin).normalized() * 5

master func door_use(id):
	stop = not stop
	open = not open
