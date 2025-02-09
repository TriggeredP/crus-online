extends KinematicBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var GIB = preload("res://Entities/Physics_Objects/Chest_Gib.tscn")

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
var type = 0
var audio_player

func _ready():
	set_collision_layer_bit(8, 1)
	audio_player = AudioStreamPlayer3D.new()
	get_parent().call_deferred("add_child", audio_player)
	yield (get_tree(), "idle_frame")
	audio_player.global_transform.origin = global_transform.origin
	audio_player.stream = load("res://Sfx/Flesh/gibbing_3.wav")
	audio_player.unit_size = 10
	audio_player.unit_db = 4
	audio_player.max_db = 4
	audio_player.pitch_scale = 0.6

func get_type():
	return type

func player_use():
	if not Global.hope_discarded:
		Global.player.UI.notify("zvhvhivj jidv ijvdkjaeui djvhduhekj vduihkeu", Color(1, 0, 0))
	else :
		if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
			for i in range(10):
				var new_gib = GIB.instance()
				
				new_gib.set_name(new_gib.name + "#" + str(new_gib.get_instance_id()))

				get_parent().add_child(new_gib)
				new_gib.global_transform.origin = global_transform.origin
				new_gib.velocity = Vector3.FORWARD.rotated(Vector3.UP, rand_range( - PI, PI))
				NetworkBridge.n_rpc(self, "spawn_gib", [get_parent().get_path(), new_gib.name])
			
			remove(null)
			NetworkBridge.n_rpc(self, "remove")
		else:
			Global.player.UI.notify("Something is keeping you from opening this door", Color(1, 0, 0))

puppet func remove_on_ready(id):
	set_collision_layer_bit(0,false)
	set_collision_mask_bit(0,false)
	set_collision_layer_bit(8, false)
	hide()

puppet func remove(id):
	set_collision_layer_bit(0,false)
	set_collision_mask_bit(0,false)
	set_collision_layer_bit(8, false)
	hide()

puppet func spawn_gib(id, recivedPath, recivedName):
	var new_gib = GIB.instance()
	get_node(recivedPath).add_child(new_gib)
	new_gib.set_name(recivedName)
