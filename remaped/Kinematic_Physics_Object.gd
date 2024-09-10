extends KinematicBody

var velocity = Vector3(0, 0, 0)
var gravity = 22
var held = false
var alerter = false
export  var grillable = false
var grill = false
var grill_health = 50
var grill_flag = false
var damager = false
export  var disabled = false
export  var usable = true
var alert_sphere = preload("res://Entities/Alert_Sphere_Big.tscn")
var blood_decal = preload("res://Entities/Decals/FleshDecal1.tscn")
export  var type = 1
export  var player_head = false
export  var particle = true
export  var mass = 1
export  var gun_rotation = false
export  var flesh = false
var angular_velocity = 0
export  var gas = false
var gas_cloud = preload("res://Entities/Bullets/Poison_Gas.tscn")
export  var collidable = false
export  var rotate_b = true
export  var shell = false
var grill_healing_item = preload("res://Entities/healing_item.tscn")
export  var stay_active = false
var impact_sound:Array
export  var sounds = false
var rot_changed = Vector3(0, 0, 0)
var t = 0
var water = false
var finished = false
var no_rot = false
var gun
var rot_towards
var rot_towards_z = 0
var rot_towards_x = 0
var rot_towards_y = 0
var new_alert_sphere
var particle_node
var sphere_collision
var distance
var glob
var first_col = true

var change_transform = true

onready var Multiplayer = Global.get_node("Multiplayer")

################################################################################

var holdId = 0

var playerIgnoreId = 0

remote func _sync_vars(recDisabled,recUsable,recGrill_health,recSphere_collision,recDamager,recHeld):
	disabled = recDisabled
	usable = recUsable
	grill_health = recGrill_health
	sphere_collision.disabled = recSphere_collision
	damager = recDamager
	held = recHeld

remote func _set_grill(value):
	grill = value

remote func _set_collision(typeA,typeB):
	set_collision_layer_bit(0, typeA)
	set_collision_mask_bit(2, typeB)
	set_collision_mask_bit(3, typeB)

remote func _set_collision_layer(numA,numB):
	set_collision_layer_bit(numA, numB)

remote func _set_collision_mask(numA,numB):
	set_collision_mask_bit(numA, numB)

remote func _spawn_fake_gas(pos):
	var fake_gas_cloud = preload("res://MOD_CONTENT/CruS Online/effects/fake_poison_gas.tscn").instance()
	get_parent().add_child(fake_gas_cloud)
	fake_gas_cloud.global_transform.origin = pos

remote func _grill(recivedPos):
	grill_flag = true
	$Gib.get_child(0).material_override = load("res://Materials/grilled.tres")
	var new_healing = grill_healing_item.instance()
	add_child(new_healing)
	new_healing.global_transform.origin = recivedPos

remote func _create_blood_decal(collider,recivedTransform,recivedBasis):
	var new_blood_decal = blood_decal.instance()
	get_node(collider).add_child(new_blood_decal)
	new_blood_decal.global_transform.origin = recivedTransform
	new_blood_decal.transform.basis = recivedBasis

remote func _remove():
	queue_free()

func syncUpdate():
	if gun != null:
		gun.syncUpdate()

var lerp_transform : Transform
var last_transform : Transform

func host_tick():
	if (global_transform.origin - last_transform.origin).length() > 0.01:
		rset_unreliable("lerp_transform", global_transform)
		Multiplayer.packages_count += 1
		last_transform = global_transform

################################################################################

func _ready()->void :
	lerp_transform = global_transform
	
	Multiplayer.connect("host_tick", self, "host_tick")
	rset_config("lerp_transform", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("global_transform", MultiplayerAPI.RPC_MODE_PUPPET)

	rset_config("holdId",MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("disabled",MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("usable",MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("grill_health",MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("damager",MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("held",MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("grill",MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("velocity",MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("stay_active",MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("finished",MultiplayerAPI.RPC_MODE_REMOTE)

	glob = Global
	if particle:
		particle_node = get_node_or_null("Particle")
	new_alert_sphere = alert_sphere.instance()
	add_child(new_alert_sphere)
	new_alert_sphere.global_transform.origin = global_transform.origin
	sphere_collision = new_alert_sphere.get_node("CollisionShape")
	sphere_collision.disabled = true
	gun = get_node_or_null("Area")
	set_collision_layer_bit(6, 1)
	set_collision_layer_bit(2, 0)
	set_collision_mask_bit(2, 1)
	set_collision_mask_bit(3, 1)
	rot_towards = global_transform.origin - velocity
	if not collidable:
		set_collision_layer_bit(0, 0)
	t += rand_range(0, 10)
	t = round(t)
	if sounds:
		impact_sound = [$Sound1]
		for sound in impact_sound:
			sound.pitch_scale -= mass * 0.1
	if gun_rotation:
		yield (get_tree(), "idle_frame")
		angular_velocity = Vector2(velocity.x, velocity.z).length()
	
	if get_tree().network_peer != null and not is_network_master():
		axis_lock_motion_x = true
		axis_lock_motion_y = true
		axis_lock_motion_z = true
		
		rpc("_get_transform")

master func _get_transform():
	rset_unreliable("lerp_transform", lerp_transform)
	rset_unreliable("global_transform", global_transform)

master func set_transform(recivedTransform):
	if is_network_master():
		finished = false
		t = 0
		velocity = Vector3.ZERO
		
		lerp_transform = recivedTransform
		global_transform = recivedTransform
	else:
		rpc("set_transform", recivedTransform)

master func add_velocity(recivedVelocity):
	if is_network_master():
		velocity += recivedVelocity
	else:
		rpc("add_velocity", recivedVelocity)

func _physics_process(delta):
	if get_tree().network_peer != null:
		if disabled:
			$CollisionShape.disabled = true
			set_physics_process(false)
			return 

		t += 1
		
		if held and get_tree().get_network_unique_id() == holdId:
			lerp_transform.origin = Global.player.weapon.hold_pos.global_transform.origin

		if is_network_master():
			
			if fmod(t, 300) == 0 and (velocity.x < 0.01 and velocity.y < 0.01):
				change_transform = false
			if velocity.x > 0.05 or velocity.y > 0.05:
				change_transform = true
			
	#		if Global.fps < 30 and not player_head:
	#			if global_transform.origin.distance_to(glob.player.global_transform.origin) > 20:
	#				return 

			if not stay_active and not gun_rotation or global_transform.origin.distance_to(glob.player.global_transform.origin) > 30:
				if fmod(t, 2) == 0:
					return 
				else :
					delta *= 2
			if grillable and grill:
				usable = false
				grill_health -= 1
			
			if grill_health <= 0 and not grill_flag:
				grill_flag = true
				$Gib.get_child(0).material_override = load("res://Materials/grilled.tres")
				var new_healing = grill_healing_item.instance()
				add_child(new_healing)
				new_healing.global_transform.origin = global_transform.origin
				rpc("_grill",new_healing.global_transform.origin)
			
			if collidable:
				if Vector2(velocity.x, velocity.z).length() > 5:
					set_collision_layer_bit(0, 0)
					set_collision_mask_bit(2, 1)
					set_collision_mask_bit(3, 1)
					rpc("_set_collision",0,1)
				elif not held:
					set_collision_layer_bit(0, 1)
					set_collision_mask_bit(2, 0)
					set_collision_mask_bit(3, 0)
					rpc("_set_collision",1,0)
			
			if player_head:
				rot_towards = lerp(rot_towards, global_transform.origin - velocity, 5 * delta)
				if rot_towards.length() > 0.5:
					look_at(Vector3(rot_towards.x + 1e-06, global_transform.origin.y, rot_towards.z), Vector3.UP)
			
			if water:
				gravity = 2
			else :
				gravity = 22

			if finished:
				return 
			
			if gun_rotation:
				rotation.y += angular_velocity
			
			if not player_head and rotate_b:
				rotation.z = lerp(rotation.z, rot_towards_z, 0.5)
				rotation.x = lerp(rotation.x, rot_towards_x, 0.5)
			if Vector3(velocity.x, 0, velocity.z).length() > 0.4 and rotate_b:
				rot_towards_x -= velocity.length()
			elif not player_head and not no_rot and not gun_rotation and not gas:
				rotation = rot_changed
			
			var collision = move_and_collide(velocity * delta)

			if collision and alerter and velocity.length() > 7:
				sphere_collision.disabled = false
			elif sphere_collision.disabled == false:
				sphere_collision.disabled = true
				
			if collision and (t < 200 or stay_active):
				if velocity.length() > 5 and flesh and Global.fps > 30:
					var new_blood_decal = blood_decal.instance()
					#print(collision.collider.get_path())
					#print(get_node(collision.collider.get_path()))
					collision.collider.add_child(new_blood_decal)
					new_blood_decal.global_transform.origin = collision.position
					new_blood_decal.transform.basis = align_up(new_blood_decal.transform.basis, collision.normal)
					rpc("_create_blood_decal",collision.collider.get_path(),new_blood_decal.global_transform.origin,new_blood_decal.transform.basis)
				if Vector2(velocity.x, velocity.z).length() > 5 and (gun_rotation or glob.implants.arm_implant.throw_bonus > 0):
					if collision.collider.has_method("damage"):
						if collision.collider.client.name != str(playerIgnoreId):
							damager = false
							print(collision.collider.client.name,"/",playerIgnoreId)
							collision.collider.damage(100, collision.normal, collision.position, global_transform.origin)
				elif sounds and abs(velocity.length()) > 2 and Global.fps > 30:
					var current_sound = 0
					impact_sound[current_sound].pitch_scale += rand_range( - 0.1, 0.1)
					impact_sound[current_sound].pitch_scale = clamp(impact_sound[current_sound].pitch_scale, 0.8, 1.2)
					impact_sound[current_sound].unit_db = velocity.length() * 0.1 - 1
					impact_sound[current_sound].play()
				if gas and velocity.length() > 4:
					var new_gas_cloud = gas_cloud.instance()
					get_parent().add_child(new_gas_cloud)
					new_gas_cloud.global_transform.origin = global_transform.origin
					rpc("_spawn_fake_gas",new_gas_cloud.global_transform.origin)
					rpc("_remove")
					queue_free()
				velocity = velocity.bounce(collision.normal) * 0.6
				angular_velocity = Vector2(velocity.x, velocity.z).length()

			if collision and t >= 200 and not player_head:
				if not stay_active:
					finished = true
				if particle:
					particle_node.emitting = false
					particle_node.hide()
			velocity.y -= gravity * delta
		else:
			global_transform = global_transform.interpolate_with(lerp_transform, delta * 10.0)

func align_up(node_basis, normal)->Basis:
	var result = Basis()
	var scale = node_basis.get_scale()

	result.x = normal.cross(node_basis.z) + Vector3(1e-05, 0, 0)
	result.y = normal + Vector3(0, 1e-05, 0)
	result.z = node_basis.x.cross(normal) + Vector3(0, 0, 1e-05)
	
	result = result.orthonormalized()
	result.x *= scale.x
	result.y *= scale.y
	result.z *= scale.z

	return result

func set_grill(value):
	if grillable:
		grill = value
		rset("grill",value)

func player_use():
	if not usable or held:
		return 
	
	held = true

	if glob.implants.arm_implant.throw_bonus > 0:
		damager = true
		rset("damager",true)
	
	rset("held",true)
	
	stay_active = true
	rset("stay_active",true)
	finished = false
	rset("finished",false)
	glob.player.weapon.hold(self)

func damage(damage, collision_n, collision_p, shooter_pos):
	if gas:
		var new_gas_cloud = gas_cloud.instance()
		get_parent().add_child(new_gas_cloud)
		new_gas_cloud.global_transform.origin = global_transform.origin
		if get_tree().network_peer != null:
				rpc("_spawn_fake_gas",new_gas_cloud.global_transform.origin)
				rpc("_remove")
		queue_free()
	if damage < 3:
		return 
	
	if get_tree().network_peer == null or get_tree().network_peer != null and is_network_master():
		velocity -= collision_n * damage / mass
	else:
		rset("velocity", velocity - collision_n * damage / mass)
	if not no_rot:
		look_at((global_transform.origin - collision_n * damage + Vector3(1e-05, 0, 0)), Vector3.UP)
		rot_changed = Vector3(0, rand_range( - PI, PI), rand_range( - PI, PI))
		rot_towards_y = rotation.y
	if gun_rotation:
		angular_velocity = velocity.length()
	
func set_water(a):
	if get_tree().network_peer == null or get_tree().network_peer != null and is_network_master():
		water = a
		velocity *= 0.5
		velocity.y = 0

func get_type():
	return type;

func physics_object():
	pass
