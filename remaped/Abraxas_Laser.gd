extends KinematicBody

var type = 1
var laser
var health = 300
var follow_speed = 0.02
var particle
var active = false
var destroyed = false
var look_towards = Vector3.ZERO
var t = 0
var disabled = true

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
	look_towards = Global.player.global_transform.origin
	laser = $Laser
	particle = $Particles
	
	laser.rset_config("global_transform", MultiplayerAPI.RPC_MODE_PUPPET)
	particle.rset_config("global_transform", MultiplayerAPI.RPC_MODE_PUPPET)

puppet func particle_visible(value = true):
	particle.visible = value

func _process(delta):
	if is_network_master():
		t += 1
		if destroyed:
			hide()
			return 
		if disabled:
			particle.hide()
			if laser.scale.z < 3:
				hide()
			laser.scale.z = lerp(laser.scale.z, 1, 0.2)
			return 
		show()
		look_towards = lerp(look_towards, get_near_player(self).player.global_transform.origin, follow_speed)
		var space = get_world().direct_space_state
		if not active:
			var active_result = space.intersect_ray(global_transform.origin, get_near_player(self).player.global_transform.origin + Vector3.UP * 0.5, [self])
			if active_result:
				if active_result.collider == Global.player or active_result.collider.has_meta("puppet"):
					active = true
				else :
					return 
		var result = space.intersect_ray(global_transform.origin, global_transform.origin - (global_transform.origin - look_towards).normalized() * 200, [self])
		if result:
			particle.show()
			particle.global_transform.origin = result.position
			laser.scale.z = lerp(laser.scale.z, global_transform.origin.distance_to(result.position) * 0.5, 0.2)
			laser.look_at(result.position, Vector3.UP)
			rpc_unreliable("particle_visible", true)
			laser.rset_unreliable("global_transform", laser.global_transform)
			particle.rset_unreliable("global_transform", particle.global_transform)
			if result.collider == Global.player or result.collider.has_meta("puppet"):
				result.collider.damage(20, result.normal, result.position, global_transform.origin)
		else :
			particle.hide()
			laser.scale.z = 400
			rpc_unreliable("particle_visible", false)
			laser.rset_unreliable("global_transform", laser.global_transform)
	else:
		set_process(false)

puppet func died():
	get_parent().get_node("Particle").show()
	get_parent().get_node("Sphere002").hide()

master func damage(dmg, nrml, pos, shoot_pos):
	if is_network_master():
		if not active:
			return 
		health -= dmg
		if health <= 0:
			destroyed = true
			died()
			rpc("died")
	else:
		rpc("damage", dmg, nrml, pos, shoot_pos)

func get_type():
	return type;
