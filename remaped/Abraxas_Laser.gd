extends KinematicBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

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
	NetworkBridge.register_rpcs(self, [
		["particle_visible", NetworkBridge.PERMISSION.SERVER],
		["died", NetworkBridge.PERMISSION.SERVER],
		["network_damage", NetworkBridge.PERMISSION.ALL]
	])
	
	look_towards = Global.player.global_transform.origin
	laser = $Laser
	particle = $Particles
	
	laser.rset_config("global_transform", MultiplayerAPI.RPC_MODE_PUPPET)
	particle.rset_config("global_transform", MultiplayerAPI.RPC_MODE_PUPPET)
	
	NetworkBridge.register_rset(laser, "global_transform", NetworkBridge.PERMISSION.SERVER)
	NetworkBridge.register_rset(particle, "global_transform", NetworkBridge.PERMISSION.SERVER)
	
	rset_config("visible", MultiplayerAPI.RPC_MODE_PUPPET)

puppet func particle_visible(id, value = true):
	particle.visible = value

func _physics_process(delta):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		t += 1
		if destroyed:
			hide()
			NetworkBridge.n_rset_unreliable(self, "visible", false)
			return 
		if disabled:
			particle.hide()
			NetworkBridge.n_rpc_unreliable(self, "particle_visible", [false])
			if laser.scale.z < 3:
				hide()
			laser.scale.z = lerp(laser.scale.z, 1, 0.2)
			NetworkBridge.n_rset_unreliable(laser, "global_transform", laser.global_transform)
			return 
		show()
		look_towards = lerp(look_towards, get_near_player(self).player.global_transform.origin  + Vector3.UP * 1.0, follow_speed)
		var space = get_world().direct_space_state
		if not active:
			var active_result = space.intersect_ray(global_transform.origin, get_near_player(self).player.global_transform.origin + Vector3.UP * 1.0, [self])
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
			NetworkBridge.n_rpc_unreliable(self, "particle_visible", [true])
			NetworkBridge.n_rset_unreliable(laser, "global_transform", laser.global_transform)
			NetworkBridge.n_rset_unreliable(particle, "global_transform", particle.global_transform)
			if result.collider == Global.player or result.collider.has_meta("puppet"):
				result.collider.damage(20, result.normal, result.position, global_transform.origin)
		else :
			particle.hide()
			laser.scale.z = 400
			NetworkBridge.n_rpc_unreliable(self, "particle_visible", [false])
			NetworkBridge.n_rset_unreliable(laser, "global_transform", laser.global_transform)
	else:
		set_physics_process(false)

puppet func died(id):
	get_parent().get_node("Particle").show()
	get_parent().get_node("Sphere002").hide()

func damage(dmg, nrml, pos, shoot_pos):
	network_damage(null, dmg, nrml, pos, shoot_pos)

master func network_damage(id, dmg, nrml, pos, shoot_pos):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		if not active:
			return 
		health -= dmg
		if health <= 0:
			destroyed = true
			died(null)
			NetworkBridge.n_rpc(self, "died")
	else:
		NetworkBridge.n_rpc(self, "network_damage", [dmg, nrml, pos, shoot_pos])

func get_type():
	return type;
