extends KinematicBody

func _ready():
	rset_config("global_transform", MultiplayerAPI.RPC_MODE_PUPPET)
	
	set_collision_mask_bit(0, 1)
	set_collision_mask_bit(1, 1)
	set_safe_margin(0)

puppet func remove():
	queue_free()

func _process(delta):
	if is_network_master():
		var space_state = get_world().direct_space_state
		
		var result_forward = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.FORWARD * 1.1)
		var result_back = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.BACK * 1.1)
		var result_left = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.LEFT * 1.1)
		var result_right = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.RIGHT * 1.1)
		var result_down = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.DOWN * 1)
		
		if result_forward and not result_back:
			if result_forward.collider == Global.player  or result_forward.collider.has_meta("puppet"):
				translate(Vector3.BACK * 2)
				rset("global_transform", global_transform)
				
		if result_back and not result_forward:
			if result_back.collider == Global.player  or result_forward.collider.has_meta("puppet"):
				translate(Vector3.FORWARD * 2)
				rset("global_transform", global_transform)
				
		if result_left and not result_right:
			if result_left.collider == Global.player  or result_forward.collider.has_meta("puppet"):
				translate(Vector3.RIGHT * 2)
				rset("global_transform", global_transform)
				
		if result_right and not result_left:
			if result_right.collider == Global.player  or result_forward.collider.has_meta("puppet"):
				translate(Vector3.LEFT * 2)
				rset("global_transform", global_transform)
				
		if not result_down:
			translate(Vector3.DOWN * 0.1)
			rset("global_transform", global_transform)
			
		if result_down:
			if result_down.collider.has_method("special_destroy"):
				result_down.collider.special_destroy()
				queue_free()
				rpc("remove")
