extends Spatial

export  var rotation_speed = 1

func _ready():
	rset_config("global_transform", MultiplayerAPI.RPC_MODE_PUPPET)
	rotation.y += rand_range(0, TAU)
	
func _physics_process(delta):
	if get_tree().network_peer != null and is_network_master():
		rset_unreliable("global_transform", global_transform)
		rotation.y -= rotation_speed * delta
