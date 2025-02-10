extends KinematicBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var PARTICLE = preload("res://Entities/Particles/Destruction_Particle.tscn")

export  var door_health = 100
var mesh_instance
var type = 1
var audio_player

var isDestroyed = false

var destroy_check_timer

func _ready():
	set_process(false)
	for child in get_children():
		if child is MeshInstance:
			mesh_instance = child
	var t = mesh_instance.transform
	audio_player = AudioStreamPlayer3D.new()
	get_parent().call_deferred("add_child", audio_player)
	yield (get_tree(), "idle_frame")
	audio_player.global_transform.origin = global_transform.origin
	audio_player.stream = load("res://Sfx/Environment/doorkick.wav")
	audio_player.unit_size = 10
	audio_player.unit_db = 2
	audio_player.max_db = 3
	
	destroy_check_timer = Timer.new()
	destroy_check_timer.wait_time = 2.0
	destroy_check_timer.one_shot = true
	destroy_check_timer.connect("timeout", self, "respawn")
	
	rset_config("door_health", MultiplayerAPI.RPC_MODE_PUPPET)
	NetworkBridge.register_rset(self, "door_health", NetworkBridge.PERMISSION.SERVER)
	
	NetworkBridge.register_rpcs(self, [
		["check_removed", NetworkBridge.PERMISSION.ALL],
		["network_destroy", NetworkBridge.PERMISSION.ALL],
		["network_damage", NetworkBridge.PERMISSION.ALL],
		["remove_on_ready", NetworkBridge.PERMISSION.SERVER],
		["remove", NetworkBridge.PERMISSION.SERVER]
	])
	
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		NetworkBridge.n_rpc(self, "check_removed")

master func check_removed(id):
	if isDestroyed:
		NetworkBridge.n_rpc_id(self, id, "remove_on_ready")

func destroy(collision_n, collision_p):
	network_destroy(null, collision_n, collision_p)

master func network_destroy(id, collision_n, collision_p):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		damage(200, collision_n, collision_p, Vector3.ZERO)
	else:
		remove(null, collision_n, collision_p)
		NetworkBridge.n_rpc(self, "network_destroy", [collision_n, collision_p])

func damage(dmg, nrml, pos, shoot_pos):
	network_damage(null, dmg, nrml, pos, shoot_pos)

master func network_damage(id, damage, collision_n, collision_p, shooter_pos):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		door_health -= damage
		if door_health <= 0:
			remove(null, collision_n, collision_p)
			NetworkBridge.n_rpc(self, "remove", [collision_n, collision_p, true])
		NetworkBridge.n_rset(self, "door_health", door_health)
	else:
		door_health -= damage
		if door_health <= 0:
			remove(null, collision_n, collision_p)
			destroy_check_timer.start()
		NetworkBridge.n_rpc(self, "network_damage", [damage, collision_n, collision_p, shooter_pos])

func get_type():
	return type;

puppet func remove_on_ready(id):
	set_collision_layer_bit(0,false)
	set_collision_mask_bit(0,false)
	hide()

puppet func remove(id, collision_n, collision_p, from_host = false):
	if not visible and from_host:
		destroy_check_timer.stop()
	else:
		isDestroyed = true
		audio_player.global_transform.origin = collision_p
		audio_player.play()
		var new_particle = PARTICLE.instance()
		get_parent().add_child(new_particle)
		new_particle.global_transform.origin = collision_p
		new_particle.look_at(global_transform.origin + collision_n * 5 + Vector3(1e-06, 0, 0), Vector3.UP)
		new_particle.material_override = mesh_instance.mesh.surface_get_material(0)
		new_particle.emitting = true
		set_collision_layer_bit(0,false)
		set_collision_mask_bit(0,false)
		hide()

func respawn():
	isDestroyed = false
	set_collision_layer_bit(0,true)
	set_collision_mask_bit(0,true)
	show()
