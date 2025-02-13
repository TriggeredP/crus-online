extends KinematicBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var GRAVITY = 22

export  var move_speed = 2
export  var run_speed = 6
export  var immune_to_fall_damage = false

var optimization_multiplier = 3
var velocity = Vector3(0, 0, 0)
var setup = true
var visibility_notifier:VisibilityNotifier
var mesh
var water = false
var time = 0
var anim_player:AnimationPlayer

export (Array, String, MULTILINE) var LINES
export (Array, Array, String, MULTILINE) var DYN_LINES = [["N"], 
["N"], 
["N"], 
["N"], 
["N"], 
["N"], 
["N"], 
["N"], 
["N"], 
["N"], 
["N"], 
["N"], 
["N"], ]

var player_distance = Vector3.ZERO
var flee = false
var dead = false
var tranq = false

export  var free = false

var active = true
var current_line = 0
var DEATH_ANIMS = ["Death1", "Death2"]
var look_at_player = false
var objective = false
var last_pos:Vector3
var random_line
var glob
var soul
var tranqtimer:Timer

onready var Multiplayer = Global.get_node("Multiplayer")

# Multiplayer stuff
################################################################################

func get_near_player() -> Dictionary:
	var oldDistance = null
	var player = null
	
	for selectedPlayer in get_tree().get_nodes_in_group("Player"):
		var distance = global_transform.origin.distance_to(selectedPlayer.global_transform.origin)
		if oldDistance == null or oldDistance > distance:
			oldDistance = distance
			player = selectedPlayer
	
	return {
		"player" : player,
		"distance" : oldDistance
	}

puppet func play_anim(id, anim,blend = -1.0,speed = 1.0):
	anim_player.play(anim,blend,speed)

puppet func stop_anim(id):
	anim_player.stop()

var lerp_mesh_rotation
var last_mesh_rotation

var lerp_transform : Transform
var last_transform : Transform

puppet func set_puppet_transform(id, recived_position, recived_rotation):
	lerp_transform.origin = recived_position
	lerp_mesh_rotation = recived_rotation

func host_tick():
	if (global_transform.origin - last_transform.origin).length() > 0.01 or (mesh.rotation - last_mesh_rotation).length() > 0.01:
		NetworkBridge.n_rpc_unreliable(self, "set_puppet_transform", [global_transform.origin, mesh.rotation])
		Multiplayer.packages_count += 1
		last_transform = global_transform
		last_mesh_rotation = mesh.rotation

################################################################################

func _ready():
	NetworkBridge.register_rpcs(self,[
		["add_velocity", NetworkBridge.PERMISSION.ALL],
		["set_flee", NetworkBridge.PERMISSION.ALL],
		["set_dead", NetworkBridge.PERMISSION.ALL],
		["set_tranquilized", NetworkBridge.PERMISSION.ALL],
		["play_anim", NetworkBridge.PERMISSION.SERVER],
		["stop_anim", NetworkBridge.PERMISSION.ALL],
		["set_puppet_transform", NetworkBridge.PERMISSION.ALL]
	])
	
	set_collision_mask_bit(10, 1)
	
	lerp_transform = global_transform
	
#	Multiplayer.connect("host_tick", self, "host_tick")
	rset_config("lerp_transform", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("lerp_mesh_rotation", MultiplayerAPI.RPC_MODE_PUPPET)
	
	soul = get_parent()
	glob = Global
	tranqtimer = Timer.new()
	add_child(tranqtimer)
	tranqtimer.wait_time = 60
	tranqtimer.one_shot = true
	tranqtimer.connect("timeout", self, "tranq_timeout")
	random_line = randi() % glob.DIALOGUE.DIALOGUE[glob.CURRENT_LEVEL].size()
	last_pos = global_transform.origin
	objective = get_parent().objective
	if glob.CURRENT_LEVEL != 7 or objective:
		optimization_multiplier = 1
	time += round(rand_range(0, 50))
	anim_player = get_parent().get_node_or_null("Nemesis/AnimationPlayer")
	mesh = get_parent().get_node_or_null("Nemesis/Armature/Skeleton")
	
	lerp_mesh_rotation = mesh.rotation
	
	visibility_notifier = VisibilityNotifier.new()
	visibility_notifier.connect("screen_entered", self, "_on_Screen_Entered")
	visibility_notifier.connect("screen_exited", self, "_on_Screen_Exited")
	if glob.CURRENT_LEVEL == 2000 and not objective:
		move_speed = move_speed * optimization_multiplier * optimization_multiplier
		run_speed *= optimization_multiplier * optimization_multiplier
		GRAVITY *= optimization_multiplier
	add_child(visibility_notifier)
	visibility_notifier.global_transform.origin = global_transform.origin
	velocity = Vector3(move_speed, 0, 0).rotated(Vector3.UP, rand_range(0, deg2rad(360)))
	mesh.look_at(global_transform.origin + Vector3(velocity.x, 0, velocity.z), Vector3.UP)
	player_distance = global_transform.origin.distance_to(glob.player.global_transform.origin)
	var collision = move_and_collide(velocity)
	yield (get_tree(), "idle_frame")
	set_collision_layer_bit(8, 1)

func _on_Screen_Entered():
	pass
#	active = true

func _on_Screen_Exited():
	pass
#	if objective:
#		return 
#	active = false

func _physics_process(delta):
	if NetworkBridge.check_connection():
		if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
			host_tick()
			
			var playerData = get_near_player()
			
			if playerData.distance > glob.draw_distance + 10:
				return 
			
			var fps = Global.fps
			
			if fmod(time, 22) == 0:
				player_distance = playerData.distance
				look_at_player = (player_distance < 4 or player_distance > 100)
			
			time += 1
			
			if player_distance > 40 and not dead and not tranq and not objective:
				anim_player.play("Idle")
				NetworkBridge.n_rpc(self, "play_anim", ["Idle"])
				return 
			
			if fps < 30:
				if Global.every_2:
					return 
			
			var pos = global_transform.origin
			var player_pos = playerData.player.global_transform.origin
			
			if not active and not dead and not flee and not free and not tranq:
				return 
			
			setup = false

			if (look_at_player and not flee and not dead and not free and not tranq):
				mesh.look_at(player_pos, Vector3.UP)
				mesh.rotation.x = 0

				velocity.x = 0
				velocity.z = 0
				anim_player.play("Idle")
				NetworkBridge.n_rpc(self, "play_anim", ["Idle"])
				return 

			if fmod(time, 200) == 0 and not flee and not tranq:
				var rand = randi() % 3
				match rand:
					1:
						velocity.x = 0
						velocity.z = 0
					2:
						velocity = Vector3(move_speed, velocity.y, velocity.z).rotated(Vector3.UP, rand_range(0, deg2rad(360)))
						mesh.look_at(pos + Vector3(velocity.x, 0, velocity.z) + Vector3(0.0001, 0, 0), Vector3.UP)
						mesh.rotation.x = 0
					3:
						pass
			if Vector3(velocity.x, 0, velocity.z).length() > 0.5 and not dead and not tranq:
				if not flee:
					anim_player.play("Walk")
					NetworkBridge.n_rpc(self, "play_anim", ["Walk"])
				else :
					anim_player.play("Run", - 1, 2)
					NetworkBridge.n_rpc(self, "play_anim", ["Run", -1, 2])
			elif not dead and not tranq:
				anim_player.play("Idle")
				NetworkBridge.n_rpc(self, "play_anim", ["Idle"])
			if water:
				if not dead:
					GRAVITY = - 4
				else :
					GRAVITY = 1
			else :
				GRAVITY = 22
				if glob.CURRENT_LEVEL == 2000 and not objective:
					GRAVITY = 22 * optimization_multiplier
			velocity.y -= GRAVITY * delta
			var a = 1
			if not fmod(time, 3) == 0 and glob.CURRENT_LEVEL == 2000 and not objective:
				return 
			if glob.CURRENT_LEVEL == 2000 and not objective:
				a = 1.5
			var collision = move_and_collide(velocity * delta)
			if collision:
				if velocity.y < - 5 * optimization_multiplier and abs(global_transform.origin.y - last_pos.y) > 7 and not immune_to_fall_damage:
					get_parent().damage(50, collision.normal, collision.position, collision.position)
				elif collision.normal.y > 0.9:
					velocity = velocity.slide(collision.normal)
					if dead or tranq:
						velocity.x *= 0.95
						velocity.z *= 0.95
				else :
					velocity = velocity.bounce(collision.normal)
					if Vector3(velocity.x, 0, velocity.z).length() > 0.5:
						mesh.look_at(pos + Vector3(velocity.x, 0, velocity.z) + Vector3(0.0001, 0, 0), Vector3.UP)
						mesh.rotation.x = 0
				last_pos = global_transform.origin
		else:
			global_transform = global_transform.interpolate_with(lerp_transform, delta * 10.0)
			mesh.rotation = lerp(mesh.rotation, lerp_mesh_rotation, delta * 10.0)

master func add_velocity(id, increase_velocity):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		if not glob.CURRENT_LEVEL == 2000:
			velocity -= increase_velocity
		else :
			velocity -= increase_velocity * optimization_multiplier
	else:
		NetworkBridge.n_rpc_id(self, 0, "add_velocity", [increase_velocity])

func alert(peepee):
	if LINES.size() != 0:
		return 
	set_flee(null)
	NetworkBridge.n_rpc(self, "set_flee")

func set_water(a):
	water = a
	move_speed = 0
	velocity.x = 0
	velocity.z = 0
	velocity.y *= 0.1

master func set_flee(id):
	if not flee:
		flee = true
		set_collision_layer_bit(8, 0)
		if not water:
			move_speed = run_speed
		velocity = Vector3(move_speed, 0, 0).rotated(Vector3.UP, rand_range(0, deg2rad(360)))
		mesh.look_at(global_transform.origin + Vector3(velocity.x, 0, velocity.z) + Vector3(0.0001, 0, 0), Vector3.UP)
		mesh.rotation.x = 0

master func set_dead(id):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		if not dead:
			set_collision_layer_bit(8, 0)
			dead = true
			if not tranq:
				var rand = randi() % DEATH_ANIMS.size()
				anim_player.play(DEATH_ANIMS[rand])
				NetworkBridge.n_rpc(self, "play_anim", [DEATH_ANIMS[rand]])
	else:
		NetworkBridge.n_rpc_id(self, 0, "set_dead")

master func set_tranquilized(id):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		if not tranq:
			set_collision_layer_bit(8, 0)
			tranq = true
			anim_player.play(DEATH_ANIMS[0])
			NetworkBridge.n_rpc(self, "play_anim", [DEATH_ANIMS[0]])
			tranqtimer.start()
	else:
		NetworkBridge.n_rpc_id(self, 0, "set_tranquilized")

func tranq_timeout():
	if dead:
		return 
	while (anim_player.is_playing() and anim_player.current_animation == DEATH_ANIMS[0]):
		yield (get_tree(), "idle_frame")
	if not dead:
		anim_player.play("Idle", - 1)
		NetworkBridge.n_rpc(self, "play_anim", ["Idle", -1])
		tranq = false
		flee = false
		set_collision_layer_bit(8, 1)

func player_use():
	if not dead and not flee and not tranq:
		if glob.implants.torso_implant.terror:
			set_flee(null)
			NetworkBridge.n_rpc(self, "set_flee")
			return 
		if LINES.size() == 0:
			glob.player.UI.message(glob.DIALOGUE.DIALOGUE[glob.CURRENT_LEVEL][random_line], true)
		else :
			if DYN_LINES[clamp(glob.LEVELS_UNLOCKED, 1, 12)][0] != "N":
				glob.player.UI.message(DYN_LINES[glob.LEVELS_UNLOCKED][current_line], true)
				current_line = clamp(current_line + 1, 0, DYN_LINES[glob.LEVELS_UNLOCKED].size() - 1)
			else :
				glob.player.UI.message(LINES[current_line], true)
				current_line = clamp(current_line + 1, 0, LINES.size() - 1)
