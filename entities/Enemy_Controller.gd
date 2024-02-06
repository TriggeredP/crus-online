extends Node





var thread
var enemies
var player
var glob
var delta
var mutex

# Multiplayer stuff
################################################################################

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

################################################################################

func _ready():
	mutex = Mutex.new()
	thread = Thread.new()
	
	
	enemies = get_tree().get_nodes_in_group("enemies")
	player = Global.player
	delta = get_physics_process_delta_time()
	if is_network_master():
		thread.start(self, "_AI")

func AI():
	while true:
		for enemy in get_tree().get_nodes_in_group("enemies"):
			var nearest_player = get_near_player(enemy)
			
			player = nearest_player.player
			
			mutex.lock()
			if player == null:
				return 
			if nearest_player.distance > glob.draw_distance + 10:
				return 
			if enemy.civ_killer:
				enemy.player_spotted = true
			if Global.every_20:
				enemy.player_distance = nearest_player.distance
				enemy.stealthed = glob.implants.torso_implant.stealth and enemy.player_distance > 20
			enemy.height_difference = player.global_transform.origin.y > enemy.global_transform.origin.y and abs(player.global_transform.origin.y - enemy.global_transform.origin.y) > 21
			enemy.anim_counter += 1
			enemy.time += 1
			if enemy.muzzleflash:
				enemy.muzzleflash.hide()
			if enemy.player_distance > enemy.ai_distance:
				return 
			if enemy.player_distance > 50 and Global.every_2:
				return 
			elif enemy.player_distance > 50 and not Global.every_2:
				delta *= 2
			if Global.every_55:
				if randi() % 2 == 1:
					enemy.shoot_mode = true
				elif not enemy.civ_killer:
					enemy.shoot_mode = false
			if enemy.move_speed == 0:
				if enemy.player_spotted and not enemy.dead and not enemy.tranq:
					enemy.rotate_towards = lerp(enemy.rotate_towards, player.global_transform.origin, 6 * delta)
					enemy.look_at(enemy.rotate_towards, Vector3.UP)
					enemy.rotation.x = 0
				enemy.shoot_mode = true
			if not enemy.player_spotted and not enemy.dead and not enemy.tranq:
				enemy.wait_for_player(delta)
			if Global.every_5:
				enemy.heading = - Vector3(player.global_transform.origin.x, 0, player.global_transform.origin.z).direction_to(Vector3(enemy.global_transform.origin.x, 0, enemy.global_transform.origin.z))
				enemy.line_of_sight = enemy.global_transform.origin.direction_to(enemy.forward_helper.global_transform.origin).dot(enemy.heading)
				enemy.heading_y = (player.global_transform.origin - enemy.global_transform.origin).normalized()
				enemy.line_of_sight_y = enemy.transform.basis.xform(Vector3.UP).dot(enemy.heading_y)
			if Global.every_20 and enemy.player_distance < 30:
				if enemy.velocity_ray.is_colliding():
					var collider = enemy.velocity_ray.get_collider()
					var normal = enemy.velocity_ray.get_collision_normal()
					var point = enemy.velocity_ray.get_collision_point()
					if is_instance_valid(collider):
						if collider.has_method("use") and collider.has_method("destroy") and not collider.get_collision_layer_bit(6) and (enemy.alerted or enemy.player_spotted):
							collider.destroy(normal, point)
						elif enemy.rand_patroller and collider.has_method("destroy") and collider.has_method("use") and ( not enemy.alerted and not enemy.player_spotted) and not enemy.pos_flag:
							if enemy.pos_flag:
								enemy.path = enemy.navigation.get_simple_path(enemy.global_transform.origin, enemy.pos2)
								enemy.pos_flag = not enemy.pos_flag
							else :
								enemy.path = enemy.navigation.get_simple_path(enemy.global_transform.origin, enemy.pos1)
								enemy.pos_flag = not enemy.pos_flag
						elif collider.has_method("use") and not collider.has_method("destroy") and not collider.get_collision_layer_bit(6) and Vector2(enemy.velocity.x, enemy.velocity.z).length() > 0.2:
							collider.use()
						elif collider.has_method("piercing_damage") and enemy.player_spotted:
							collider.piercing_damage(200, normal, point, enemy.global_transform.origin)
			enemy.velocity.y -= enemy.gravity * enemy.delta
			if not enemy.dead and not enemy.tranq:
				if enemy.player_spotted:
					enemy.player_spotted()
				enemy.track_player(delta)
				if not enemy.sight_potential and enemy.player_distance > 20 and not Global.every_20 and not enemy.alerted and not enemy.player_spotted:
					return 
				if enemy.path.size() > 0 and ((enemy.player_distance > enemy.engage_distance and ( not enemy.shoot_mode or enemy.melee)) or not enemy.in_sight) and enemy.player_spotted:
						enemy.find_path(delta)
				else :
					if enemy.in_sight:
						enemy.active(delta)
					else :
						enemy.reaction_timer = clamp(enemy.reaction_timer, 0, enemy.reaction_time + 1) - 5 * delta
			elif enemy.is_on_floor():
					enemy.velocity.x *= 0.95
					enemy.velocity.z *= 0.95
			mutex.unlock()
		yield (get_tree(), "physics_frame")
		
func _exit_tree():
	thread.wait_to_finish()
