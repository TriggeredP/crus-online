extends KinematicBody

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
	
	if not get_tree().network_peer != null and is_network_master():
		rpc("_get_transform")
		rpc("check_removed")

master func _get_transform():
	rset_unreliable("global_transform", global_transform)

func _physics_process(delta):
	if get_tree().network_peer != null and is_network_master():
		if not open and not stop:
			rotation.y += rotation_speed * delta
			rotation_counter += rad2deg(rotation_speed * delta)
			rset_unreliable("global_transform", global_transform)
		if open and not stop:
			rotation.y -= rotation_speed * delta
			rotation_counter += rad2deg(rotation_speed * delta)
			rset_unreliable("global_transform", global_transform)
		if rotation_counter > 90:
			rotation_counter = 0
			stop = true

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

master func use():
	if get_tree().network_peer != null and is_network_master():
		stop = not stop
		open = not open
	else:
		rpc("use")

puppet func remove_on_ready():
	set_collision_layer_bit(0,false)
	set_collision_mask_bit(0,false)
	set_collision_layer_bit(8, false)
	hide()

puppet func remove(collision_n, collision_p):
	audio_player.global_transform.origin = collision_p
	audio_player.play()
	var new_particle = PARTICLE.instance()
	get_parent().add_child(new_particle)
	new_particle.global_transform.origin = collision_p
	new_particle.look_at(global_transform.origin + collision_n * 5 + Vector3(1e-07, 0, 0), Vector3.UP)
	new_particle.material_override = mesh_instance.mesh.surface_get_material(0)
	new_particle.emitting = true
	set_collision_layer_bit(0,false)
	set_collision_mask_bit(0,false)
	set_collision_layer_bit(8, false)
	hide()
