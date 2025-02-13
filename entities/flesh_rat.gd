extends KinematicBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var GRAVITY = 22
export  var move_speed:float = 2
export  var attack_distance = 1
export  var run_speed = 6
export  var anim_speed = 1
export  var jumper = true
export  var immortal = false
var immortal_death_time = 200
var velocity = Vector3(0, 0, 0)
var weapon
var mesh
var _floor = false
var water = false
var time = 0
var anim_player:AnimationPlayer
var flee = false
var dead = false
var chatter_sound
var chatter_on = false
var DEATH_ANIMS = ["Death1", "Death2"]

onready var Multiplayer = Global.get_node("Multiplayer")

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

puppet func set_animation(id, anim:String, speed:float)->void :
	anim_player.play(anim)
	anim_player.playback_speed = speed
	
puppet func play_chatter(id):
	chatter_sound.play()

var lerp_transform : Transform
var last_transform : Transform

func host_tick():
	if (global_transform.origin - last_transform.origin).length() > 0.01:
		rset_unreliable("lerp_transform", global_transform)
		Multiplayer.packages_count += 1
		last_transform = global_transform

################################################################################

func _ready():
	NetworkBridge.register_rpcs(self,[
		["add_velocity", NetworkBridge.PERMISSION.ALL],
		["set_animation", NetworkBridge.PERMISSION.SERVER],
		["play_chatter", NetworkBridge.PERMISSION.SERVER]
	])
	
	lerp_transform = global_transform
	
#	Multiplayer.connect("host_tick", self, "host_tick")
	rset_config("lerp_transform", MultiplayerAPI.RPC_MODE_PUPPET)
	
	if immortal:
		get_parent().immortal = true
	weapon = $Rotation_Helper / Weapon
	time += round(rand_range(0, 50))
	anim_player = get_parent().get_node_or_null("Nemesis/AnimationPlayer")
	anim_player.play("Idle")
	NetworkBridge.n_rpc(self, "set_animation", ["Idle", 1])
	mesh = get_parent().get_node_or_null("Nemesis/Armature/Skeleton")
	chatter_sound = get_node_or_null("SFX/Chatter")
	chatter_on = is_instance_valid(chatter_sound)
	velocity = Vector3(move_speed, 0, 0).rotated(Vector3.UP, rand_range(0, deg2rad(360)))
	look_at(global_transform.origin + Vector3(velocity.x, 0, velocity.z), Vector3.UP)
	yield (get_tree(), "idle_frame")
	get_parent().new_alert_sphere.get_node("CollisionShape").disabled = true

func _physics_process(delta):
	if NetworkBridge.check_connection():
		if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
			host_tick()
			
			if get_near_player().distance > Global.draw_distance + 10:
				return 
			if immortal and dead:
				immortal_death_time -= 1
				if immortal_death_time == 0:
					get_parent().dead = false
					get_parent().dead_body.get_node("CollisionShape").disabled = true
					get_parent().torso.get_node("CollisionShape").disabled = false
					get_parent().health = 50
					dead = false
					immortal_death_time = 200
					anim_player.play("Undie")
					NetworkBridge.n_rpc(self, "set_animation", ["Undie", 1])
					yield (get_tree(), "idle_frame")
			if get_near_player().distance > 20:
				velocity.x = 0
				velocity.z = 0
			elif not dead:
				if chatter_on:
					
					if not chatter_sound.playing:
						chatter_sound.play()
						NetworkBridge.n_rpc(self, "play_chatter")
			time += 1
			if get_near_player().distance < 3 and not dead and _floor and get_near_player().distance > 1 and jumper:
				velocity *= 2
				velocity.y += 5
			if (get_near_player().distance < attack_distance or get_near_player().distance > 20) and not flee and not dead and not anim_player.current_animation == "Undie":
				look_at(get_near_player().player.global_transform.origin, Vector3.UP)
				rotation.x = 0

				velocity.x = 0
				velocity.z = 0
				
				if get_near_player().distance < attack_distance:
					weapon.AI_shoot()
					anim_player.play("Attack", - 1, 1)
					NetworkBridge.n_rpc(self, "set_animation", ["Attack", 1])
			else :
				if fmod(time, 20) == 0 and not dead and not anim_player.current_animation == "Undie":
					velocity = - move_speed * (global_transform.origin - get_near_player().player.global_transform.origin).normalized()
					look_at(global_transform.origin + velocity, Vector3.UP)
					rotation.x = 0
				if Vector3(velocity.x, 0, velocity.z).length() > 0.4 and not dead and not anim_player.current_animation == "Undie":
					if not flee:
						anim_player.play("Walk", - 1, anim_speed)
						NetworkBridge.n_rpc(self, "set_animation", ["Walk", anim_speed])
					else :
						anim_player.play("Run", - 1, 2)
						NetworkBridge.n_rpc(self, "set_animation", ["Walk", 2])
				elif not dead and not anim_player.current_animation == "Undie":
					anim_player.play("Idle")
					NetworkBridge.n_rpc(self, "set_animation", ["Idle", 1])
			if water:
				GRAVITY = 2
			else :
				GRAVITY = 22
			velocity.y -= GRAVITY * delta

			if dead or anim_player.current_animation == "Undie":
				velocity.x *= 0.9
				velocity.z *= 0.9
			var collision = move_and_collide(velocity * delta)
			if collision:
				if collision.normal.y > 0.9:
					velocity = velocity.slide(collision.normal)
					_floor = true
				else :
					_floor = false
					velocity = velocity.bounce(collision.normal)
					if Vector3(velocity.x, 0, velocity.z).length() > 0.4:
						look_at(global_transform.origin + Vector3(velocity.x, 0, velocity.z) + Vector3(0.0001, 0, 0), Vector3.UP)
						rotation.x = 0
			else :
				_floor = false
		else:
			global_transform = global_transform.interpolate_with(lerp_transform, delta * 10.0)

master func add_velocity(id, increase_velocity):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		velocity -= increase_velocity
	else:
		NetworkBridge.n_rpc_id(self, 0, "add_velocity", [increase_velocity])

func set_water(a):
	water = a
	velocity.y = 0

func set_flee():
	pass
	
func set_dead():
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		if not dead:
			dead = true
			if not immortal:
				for child in get_parent().colliders.get_children():
					child.get_child(0).disabled = true
			var randomDeath = randi() % DEATH_ANIMS.size()
			anim_player.play(DEATH_ANIMS[randomDeath])
			NetworkBridge.n_rpc(self, "set_animation", [DEATH_ANIMS[randomDeath], 1])
