extends KinematicBody

enum {FORWARD, RIGHT, BACK, LEFT}
const DIR = [Vector3.FORWARD * 2, Vector3.RIGHT * 2, Vector3.BACK * 2, Vector3.LEFT * 2]
var current_dir = DIR[FORWARD]
var player_dir
var step_count = 59
var step_length = 100
var last_pos
var next_pos
var space_state
var result_forward
var result_back
var result_left
var result_right
var result_current
onready var mesh = $crab
var t = 0

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

func _ready():
	rset_config("global_transform", MultiplayerAPI.RPC_MODE_PUPPET)
	
	set_collision_mask_bit(1, 1)
	set_safe_margin(0)
	last_pos = global_transform.origin
	next_pos = global_transform.origin + current_dir

func _physics_process(delta):
	if is_network_master():
		if get_near_player(self).distance > 20:
			return 
		
		look()
		
		rset("global_transform", global_transform)
		
		step_count += 1
		if step_count == 60:
			space_state = get_world().direct_space_state
			result_forward = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.FORWARD * 1)
			result_back = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.BACK * 1)
			result_left = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.LEFT * 1)
			result_right = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.RIGHT * 1)
			result_current = space_state.intersect_ray(global_transform.origin, global_transform.origin + current_dir * 0.5)
			if result_current:
				if result_forward and not result_right:
					current_dir = DIR[RIGHT]
				if result_right and not result_back:
					current_dir = DIR[BACK]
				if result_back and not result_left:
					current_dir = DIR[LEFT]
				if result_left and not result_forward:
					current_dir = DIR[FORWARD]
			if player_dir != null:
				if not space_state.intersect_ray(global_transform.origin, global_transform.origin + player_dir * 0.5):
					current_dir = player_dir
				else :
					player_dir = null
		if step_count == 60:
			step_count = 0
			last_pos = global_transform.origin
			next_pos = global_transform.origin + current_dir
			mesh.look_at(global_transform.origin - current_dir, Vector3.UP)
		else :
			if result_back and result_forward and result_left and result_right:
				return 
			global_transform.origin = lerp(global_transform.origin, next_pos, 0.3)

func look():
	var space_state = get_world().direct_space_state
	var result_forward = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.FORWARD * 100)
	var result_back = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.BACK * 100)
	var result_left = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.LEFT * 100)
	var result_right = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.RIGHT * 100)
	
	if result_forward:
		if result_forward.collider == Global.player or result_forward.collider.has_meta("puppet") or result_forward.collider.has_method("already_dead"):
			player_dir = DIR[FORWARD]
			
	if result_back:
		if result_back.collider == Global.player or result_back.collider.has_meta("puppet") or result_back.collider.has_method("already_dead"):
			player_dir = DIR[BACK]
			
	if result_right:
		if result_right.collider == Global.player or result_right.collider.has_meta("puppet") or result_right.collider.has_method("already_dead"):
			player_dir = DIR[RIGHT]
			
	if result_left:
		if result_left.collider == Global.player or result_left.collider.has_meta("puppet") or result_left.collider.has_method("already_dead"):
			player_dir = DIR[LEFT]

func _on_Area_area_entered(area):
	pass

func _on_Area_body_entered(body):
	if body.get_collision_layer_bit(0):
		return 
	if body.has_method("damage"):
		body.damage(100, current_dir.normalized(), global_transform.origin, global_transform.origin)
