extends KinematicBody

var PARTICLE = preload("res://Entities/Particles/Destruction_Particle.tscn")

export  var door_health = 100
var mesh_instance
var type = 1
var audio_player

var isDestroyed = false

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
	
	if not get_tree().network_peer != null and is_network_master():
		rpc("check_removed")

master func check_removed():
	if isDestroyed:
		rpc_id(get_tree().get_rpc_sender_id(),"remove_on_ready")

master func destroy(collision_n, collision_p):
	if get_tree().network_peer != null and is_network_master():
		damage(200, collision_n, collision_p, Vector3.ZERO)
	else:
		rpc("destroy", collision_n, collision_p)

master func damage(damage, collision_n, collision_p, shooter_pos):
	if get_tree().network_peer != null and is_network_master():
		door_health -= damage
		if door_health <= 0:
			isDestroyed = true
			remove(collision_n, collision_p)
			rpc("remove", collision_n, collision_p)
	else:
		rpc("damage", damage, collision_n, collision_p, shooter_pos)

func get_type():
	return type;

puppet func remove_on_ready():
	set_collision_layer_bit(0,false)
	set_collision_mask_bit(0,false)
	hide()

puppet func remove(collision_n, collision_p):
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
