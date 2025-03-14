extends StaticBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

func _ready():
	rset_config("global_transform", MultiplayerAPI.RPC_MODE_PUPPET)
	NetworkBridge.register_rset(self, "global_transform", NetworkBridge.PERMISSION.SERVER)
	
	set_collision_mask_bit(0, 1)
	set_collision_mask_bit(1, 1)
	set_collision_mask_bit(4, 1)

func get_near_player(object) -> Dictionary:
	var oldDistance = null
	var checkPlayer = null
	
	for selectedPlayer in get_tree().get_nodes_in_group("Player"):
		var distance = object.global_transform.origin.distance_to(selectedPlayer.global_transform.origin)
		if oldDistance == null or oldDistance > distance:
			oldDistance = distance
			checkPlayer = selectedPlayer
	
	return {
		"player" : checkPlayer,
		"distance" : oldDistance
	}

func _physics_process(delta):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		
		var space_state = get_world().direct_space_state
		var result_down = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.DOWN * 1)
		
		if not result_down:
			translate(Vector3.DOWN * 0.1)
			NetworkBridge.n_rset(self, "global_transform", global_transform)
		
		if get_near_player(self).distance > 3:
			return 
		
		var result_forward = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.FORWARD * 1.1)
		var result_back = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.BACK * 1.1)
		var result_left = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.LEFT * 1.1)
		var result_right = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.RIGHT * 1.1)
		
		if result_forward and not result_back:
			if result_forward.collider == Global.player or result_forward.collider.has_meta("puppet"):
				translate(Vector3.BACK * 2)
				NetworkBridge.n_rset(self, "global_transform", global_transform)
				
		if result_back and not result_forward:
			if result_back.collider == Global.player or result_back.collider.has_meta("puppet"):
				translate(Vector3.FORWARD * 2)
				NetworkBridge.n_rset(self, "global_transform", global_transform)
				
		if result_left and not result_right:
			if result_left.collider == Global.player or result_left.collider.has_meta("puppet"):
				translate(Vector3.RIGHT * 2)
				NetworkBridge.n_rset(self, "global_transform", global_transform)
				
		if result_right and not result_left:
			if result_right.collider == Global.player or result_right.collider.has_meta("puppet"):
				translate(Vector3.LEFT * 2)
				NetworkBridge.n_rset(self, "global_transform", global_transform)
