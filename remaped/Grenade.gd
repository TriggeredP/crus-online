extends KinematicBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

enum E_TYPE{GAS, EXPLOSION, NAIL, BLOOD, SLEEP}
export (E_TYPE) var EXPLOSION_TYPE = 0
var velocity = Vector3(0, 0, 0)
export  var init_gravity = 22
var gravity = 22
export  var type = 1
export  var homing_speed = 30
export  var homing_turn_rate:float = 0.05
export  var homing = false
export  var detonate_on_impact = false
export  var player_head = false
export  var particle = true
export  var mass = 1
export  var tranq = false
var targets:Array
var current_target
var explosion_flag = false
export  var rotate_b = true
export  var shell = false
export  var stay_active = false
export  var home_on_player = false
var impact_sound:Array
var explosion_types:Array = [preload("res://Entities/Bullets/Poison_Gas.tscn"), preload("res://Entities/Bullets/Explosion.tscn"), null, preload("res://Entities/Bullets/Explosion_Blood.tscn"), preload("res://Entities/Bullets/Sleep_Gas.tscn")]
export  var sounds = false
var rot_changed = Vector3(0, 0, 0)
var t = 0
var water = false
var finished = false
var gun
var rot_towards_z = 0
var rot_towards_x = 0
var rot_towards_y = 0
export  var shrapnel_flag = false
export  var timed = false
export  var time = 1
var timer:Timer
var flechette = preload("res://Entities/Decals/Flechette.tscn")

################################################################################

var explosion_types_path = [
	"res://Entities/Bullets/Poison_Gas.tscn",
	"res://Entities/Bullets/Explosion.tscn",
	null,
	"res://Entities/Bullets/Explosion_Blood.tscn",
	"res://Entities/Bullets/Sleep_Gas.tscn"
]

puppet func _spawn_shrapnel(id, recivedPath, recivedObject, recivedName, recivedTransform, recivedShrapnel):
	var newObject = load(recivedObject).instance()
	newObject.set_name(recivedName)
	get_node(recivedPath).add_child(newObject)
	newObject.global_transform = recivedTransform
	newObject.shrapnel_flag = recivedShrapnel

puppet func _create_object(id, recivedPath, recivedObject, recivedName, recivedTransform):
	var newObject = load(recivedObject).instance()
	newObject.set_name(recivedName)
	get_node(recivedPath).add_child(newObject)
	newObject.global_transform = recivedTransform

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

puppet func _set_transform(id, recived_transform, recived_dart_rotation = null):
	global_transform = recived_transform
	
	if recived_dart_rotation != null:
		$Position3D.look_at(recived_dart_rotation, Vector3.UP)

puppet func _delete(id):
	hide()
	global_translation = Vector3(-1000, -1000, -1000)
	
	set_process(false)
	set_physics_process(false)
	
	#queue_free()

################################################################################

var have_boresound = false

var boresounds = []

func update_rpcs():
	NetworkBridge.register_rpcs(self, [
		["_spawn_shrapnel", NetworkBridge.PERMISSION.SERVER],
		["_create_object", NetworkBridge.PERMISSION.SERVER],
		["_set_transform", NetworkBridge.PERMISSION.SERVER],
		["_delete", NetworkBridge.PERMISSION.SERVER],
		["play_sound", NetworkBridge.PERMISSION.SERVER],
		["stop_sound", NetworkBridge.PERMISSION.SERVER]
	])

var ignore_id = null

func _ready():
	update_rpcs()
	
	if tranq:
		set_collision_mask_bit(10, 1)
	
	if has_node("/Boresound"):
		print("has bore sound")
		boresounds = [$Boresound, $Boresound2]
		have_boresound = true
	
	gun = get_node_or_null("Area")
	set_collision_layer_bit(6, 1)
	set_collision_layer_bit(0, 0)
	timer = get_node_or_null("Timer")
	if timer != null:
		timer.wait_time = time
		timer.start()
	t += rand_range(0, 10)
	if sounds:
		impact_sound = [$Sound1]
		for sound in impact_sound:
			sound.pitch_scale -= mass * 0.1

func flechette(result)->void :
	if NetworkBridge.n_is_network_master(self):
		if result.collider.get_collision_layer_bit(0) and randi() % 2 == 1:
			var decal_new
			decal_new = flechette.instance()
			result.collider.add_child(decal_new)
			decal_new.global_transform.origin = result.position
			decal_new.look_at((global_transform.origin), Vector3.UP)
		if result.collider.has_method("damage"):
			result.collider.damage(60, result.normal, result.position, global_transform.origin)

func _physics_process(delta):
	if NetworkBridge.check_connection():
		if NetworkBridge.n_is_network_master(self):
			
			if tranq:
				$Position3D.look_at(global_transform.origin - velocity, Vector3.UP)
				NetworkBridge.n_rpc_unreliable(self, "_set_transform", [global_transform, global_transform.origin - velocity])
			else:
				NetworkBridge.n_rpc_unreliable(self, "_set_transform", [global_transform])
			
			if timer != null:
				if timer.is_stopped():
					if EXPLOSION_TYPE == E_TYPE.NAIL:
						var space_state = get_world().direct_space_state
						for i in range(1000):
							var dir = (Vector3.FORWARD * 100).rotated(Vector3.LEFT, rand_range( - PI, 0))
							dir = dir.rotated(Vector3.UP, rand_range( - PI, PI))
							var result = space_state.intersect_ray(global_transform.origin, global_transform.origin + dir, [self])
							if result:
								flechette(result)
						NetworkBridge.n_rpc(self, "_delete")
						_delete(null)
						return 
					var new_explosion = explosion_types[EXPLOSION_TYPE].instance()
					new_explosion.set_name(new_explosion.name + "#" + str(new_explosion.get_instance_id()))
					get_parent().add_child(new_explosion)
					new_explosion.global_transform.origin = global_transform.origin
					explosion_flag = true
					NetworkBridge.n_rpc(self, "_create_object", [get_parent().get_path(), explosion_types_path[EXPLOSION_TYPE], new_explosion.name, new_explosion.global_transform])
					NetworkBridge.n_rpc(self, "_delete")
					_delete(null)
			if home_on_player:
				current_target = get_near_player(self).player
			if (homing or home_on_player) and current_target != null:
				gravity = 0
				velocity = lerp(velocity, - homing_speed * (global_transform.origin - (current_target.global_transform.origin + Vector3(0, 1, 0))).normalized(), homing_turn_rate)
			if homing and velocity.length() < 3:
				if have_boresound:
					$Boresound.stop()
					NetworkBridge.n_rpc(self, "stop_sound", [0])
			elif homing:
				if have_boresound and not $Boresound.playing:
					$Boresound.play()
					NetworkBridge.n_rpc(self, "play_sound", [0])
			if velocity.length() < 5 and not explosion_flag and not homing and not timed and not home_on_player and not tranq:
				if not shrapnel_flag:
					var shrapnel_rotation = Vector3(1, 1, 0).rotated(Vector3.UP, deg2rad(rand_range(0, 180)))
					for i in range(4):
						shrapnel_rotation = shrapnel_rotation.rotated(Vector3.UP, deg2rad(90))
						var shrapnel = self.duplicate()
						shrapnel.set_name(shrapnel.name + "#" + str(shrapnel.get_instance_id()))
						get_parent().add_child(shrapnel)
						shrapnel.shrapnel_flag = true
						shrapnel.global_transform.origin = global_transform.origin
						shrapnel.set_velocity(30, (shrapnel.global_transform.origin - (shrapnel.global_transform.origin - shrapnel_rotation)).normalized(), global_transform.origin)

						NetworkBridge.n_rpc(self, "_spawn_shrapnel", [get_parent().get_path(), "res://MOD_CONTENT/CruS Online/effects/fake_Grenade.tscn", shrapnel.name, shrapnel.global_transform, true])
				var new_explosion = explosion_types[EXPLOSION_TYPE].instance()
				add_child(new_explosion)
				new_explosion.global_transform.origin = global_transform.origin
				explosion_flag = true
				NetworkBridge.n_rpc(self, "_create_object", [get_parent().get_path(), explosion_types_path[EXPLOSION_TYPE], new_explosion.name, new_explosion.global_transform])
			if water:
				gravity = 2
			else :
				gravity = init_gravity
			if finished:
				return 
			t += 1
			if not player_head and rotate_b:
				rotation.y = lerp(rotation.y, rot_towards_y, 0.01)
				rotation.z = lerp(rotation.z, rot_towards_z, 0.01)
				rotation.x = lerp(rotation.x, rot_towards_x, 0.01)
			if Vector3(velocity.x, 0, velocity.z).length() > 0.4 and rotate_b:
				rot_towards_x += velocity.y
				rot_towards_z += velocity.x
				rot_towards_y += velocity.z
			elif not player_head and not tranq:
				rotation = rot_changed
			var collision = move_and_collide(velocity * delta)
			if collision and (t < 200 or stay_active):
				if tranq:
						if collision.collider.has_method("tranquilize"):
							collision.collider.tranquilize(true)
						NetworkBridge.n_rpc(self, "_delete")
						_delete(null)
				if detonate_on_impact or (collision.collider == Global.player and not shrapnel_flag):
					var new_explosion = explosion_types[EXPLOSION_TYPE].instance()
					get_parent().add_child(new_explosion)
					new_explosion.global_transform.origin = global_transform.origin
					explosion_flag = true
					NetworkBridge.n_rpc(self, "_create_object", [get_parent().get_path(), explosion_types_path[EXPLOSION_TYPE], new_explosion.name, new_explosion.global_transform])
					NetworkBridge.n_rpc(self, "_delete")
					_delete(null)
				if collision.collider.has_method("destroy"):
					collision.collider.destroy(collision.normal, collision.position)
					return 
				if sounds and abs(velocity.length()) > 1:
					var current_sound = randi() % impact_sound.size()
					impact_sound[current_sound].pitch_scale += rand_range( - 0.1, 0.1)
					impact_sound[current_sound].unit_db = velocity.length() * 0.1 - 1
					impact_sound[current_sound].play()
				velocity = velocity.bounce(collision.normal) * 0.4
			if collision and t >= 200:
				if not stay_active:
					rotation = rot_changed
					finished = true
				if particle:
					$Particle.emitting = false
					$Particle.hide()
			velocity.y -= gravity * delta

func set_velocity(damage, collision_n, collision_p):
	velocity -= collision_n * damage / mass
	rot_changed = Vector3(0, rand_range( - PI, PI), rand_range( - PI, PI))
	
func set_water(a):
	water = a
	velocity *= 0.5
	velocity.y = 0

func get_type():
	return type;

func physics_object():
	pass

func _on_Area_body_entered(body):
	if NetworkBridge.n_is_network_master(self):
		if "head" in body:
			if body.head and current_target == null:
				current_target = body

func _on_Bore_entered(body):
	if NetworkBridge.n_is_network_master(self):
		if "head" in body:
			if body.head:
				var drillsound = $Boresound2
				remove_child(drillsound)
				body.add_child(drillsound)
				body.boresound = drillsound
				if is_instance_valid(drillsound):
					drillsound.play()
					NetworkBridge.n_rpc(self, "play_sound", [1])
				body.bored = true
				NetworkBridge.n_rpc(self, "_delete")
				_delete(null)

puppet func play_sound(id, soundId = 0):
	if have_boresound:
		boresounds[soundId].play()

puppet func stop_sound(id, soundId = 0):
	if have_boresound:
		boresounds[soundId].stop()
