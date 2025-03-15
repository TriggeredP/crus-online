extends KinematicBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

export  var turn_amount = 0.3
var in_use = false
var init_player_basis
var last_rpm = 0
var time = 0
var gravity = 22
var speed = 0
var rot_target = 0
export  var max_speed = 30
var velocity = Vector3.ZERO
var velocity_target = Vector3.ZERO

var last_transform : Transform
var lerp_transform : Transform

var default_rotation

var tick = 0

var drive_id = null

puppet func client_set_lerp_transform(id, recived_transform):
	lerp_transform = recived_transform

master func set_lerp_transform(id, recived_transform):
	lerp_transform = recived_transform
	NetworkBridge.n_rpc_unreliable(self, "client_set_lerp_transform", [recived_transform])

func host_tick():
	tick += 1
	if (global_transform.origin - last_transform.origin).length() > 0.01 and tick % 2 == 0:
		last_transform = global_transform
		lerp_transform = global_transform
		
		if NetworkBridge.n_is_network_master(self):
			NetworkBridge.n_rpc_unreliable(self, "client_set_lerp_transform", [lerp_transform])
		else:
			NetworkBridge.n_rpc_unreliable(self, "set_lerp_transform", [lerp_transform])
		
		tick = 0

var camera_rotation
var car_camera

func _ready():
	lerp_transform = global_transform
	
	car_camera = $Car/Camera
	default_rotation = car_camera.rotation

	camera_rotation = Spatial.new()
	$Car.add_child(camera_rotation)
	
	camera_rotation.translation = car_camera.translation
	
	$Car.remove_child(car_camera)
	camera_rotation.add_child(car_camera)
	
	car_camera.translation = Vector3.ZERO
	
	NetworkBridge.register_rpcs(self, [
		["client_set_lerp_transform", NetworkBridge.PERMISSION.SERVER],
		["set_lerp_transform", NetworkBridge.PERMISSION.ALL],
		["_stop_sound", NetworkBridge.PERMISSION.ALL],
		["_set_master", NetworkBridge.PERMISSION.ALL],
		["set_in_use", NetworkBridge.PERMISSION.ALL]
	])
	
	set_collision_layer_bit(8, 1)

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

func _physics_process(delta):
	if drive_id == NetworkBridge.get_id():
		var roty = rotation.y
		var n = Vector3.ZERO
		var c = 0
		var colliding = false
		for r in $RayCasts.get_children():
			if r.is_colliding():
				n += r.get_collision_normal()
				c += 1
				colliding = true
		if c != 0:
			n = n / c
		transform.basis = transform.basis.orthonormalized().slerp(align_up(transform.basis, n), 0.05)
		rotation.y = roty
		if in_use:
			host_tick()
			Global.player.global_rotation.y = global_rotation.y
			
			$SFX_Engine.pitch_scale = (abs(speed) + 0.01) * 0.1
			$SFX_Engine.play()
			if colliding:
				if Input.is_action_pressed("movement_jump"):
					speed = lerp(speed, 0, delta * 5)
				if Input.is_action_pressed("movement_forward"):
					speed += 1
					speed = clamp(speed, - max_speed, max_speed)
				if Input.is_action_pressed("movement_backward"):
					speed -= 1
					speed = clamp(speed, - max_speed / 2, max_speed)
			speed = lerp(speed, 0, delta)
			var vely = velocity.y
			velocity_target = (global_transform.origin - transform.xform(Vector3.FORWARD)).normalized() * speed
			velocity = lerp(velocity, velocity_target, delta * 3)
			velocity_target = lerp(velocity_target, Vector3(0, velocity_target.y, 0), delta * 5)
			velocity.y = vely
			if colliding:
				if Input.is_action_pressed("movement_left"):
					rot_target += speed * delta * 0.1
					
				elif Input.is_action_pressed("movement_right"):
					rot_target -= speed * delta * 0.1
					
				if abs(rotation.y - rot_target) >= PI * 2:
					rotation.y = rot_target
				rot_target = lerp(rot_target, 0, delta * 2)
				rotate_object_local(Vector3.UP, rot_target * delta * 3)
			Global.player.global_transform.origin = $Car / Player_Pos.global_transform.origin
		else :
			velocity = lerp(velocity, Vector3.ZERO, delta * 3)
			$SFX_Engine.stop()
		velocity.y -= gravity * delta
		velocity = move_and_slide(velocity, Vector3.UP, false, 4)
	else:
		global_transform = global_transform.interpolate_with(lerp_transform, delta * 10.0)

remote func _stop_sound(id):
	$SFX_Engine.stop()

func _process(delta):
	if Input.is_action_just_pressed("Use") and in_use and (drive_id == NetworkBridge.get_id() or drive_id == null and NetworkBridge.n_is_network_master(self)):
		eject()

#func _input(event):
#	if drive_id == NetworkBridge.get_id() and in_use:
#		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
#			if not Input.is_action_pressed("reload"):
#				var x_mouse_sensitivity = Global.mouse_sensitivity
#				var y_mouse_sensitivity = Global.mouse_sensitivity
#
#				var sensitivity = x_mouse_sensitivity * car_camera.fov / Global.FOV
#
#				var rot_deg_y = deg2rad(event.relative.y * sensitivity)
#				if Global.invert_y:
#					rot_deg_y *= - 1
#				camera_rotation.rotate_x(rot_deg_y)
#				if Global.player.max_gravity > 0:
#					car_camera.rotate_y(deg2rad(event.relative.x * sensitivity * - 1))
#				else:
#					car_camera.rotate_y(deg2rad(event.relative.x * sensitivity))
#				var camera_rot = camera_rotation.rotation_degrees
#				camera_rot.x = clamp(camera_rot.x, - 75, 75)
#				camera_rotation.rotation_degrees = camera_rot

func eject():
		car_camera.current = false
		Global.player.transform.basis = init_player_basis * $Car / Player_Pos.transform.basis
		Global.player.player_velocity = Vector3.ZERO
		Global.player.set_collision_mask_bit(7, true)
		$CollisionShape.disabled = true
		Global.player.global_transform.origin = $ExitPos.global_transform.origin
		
		Global.player.playerPuppet.set_sit(null, false)
		Global.player.car = null
		
		set_in_use(null, false)
		NetworkBridge.n_rpc(self, "set_in_use", [false])
		
		yield (get_tree(), "idle_frame")
		$CollisionShape.disabled = false
		Global.player.crush_check.disabled = false
		Global.player.weapon.left_arm_mesh.show()
		Global.player.get_parent().show()
		Global.player.grab_hand.show()
		Global.player.show()
		Global.player.player_view.current = true
		Global.player.weapon.disabled = false
		Global.player.crush_check.disabled = false
		Global.player.disabled = false
		
		_stop_sound(null)
		NetworkBridge.n_rpc(self, "_stop_sound")

remote func set_in_use(id, recived_value):
	in_use = recived_value
	
	if in_use:
		drive_id = id
	else:
		drive_id = null

func player_use():
	if not in_use:
		car_camera.rotation = default_rotation
		car_camera.current = true
		init_player_basis = Global.player.transform.basis
		
		Global.player.playerPuppet.set_sit(null, true)
		Global.player.car = self

		Global.player.get_parent().hide()
		Global.player.hide()
		Global.player.grab_hand.hide()
		Global.player.weapon.disabled = true
		Global.player.crush_check.disabled = true
		Global.player.disabled = true
		Global.player.set_collision_mask_bit(7, false)
		yield (get_tree(), "idle_frame")
		
		set_in_use(NetworkBridge.get_id(), true)
		NetworkBridge.n_rpc(self, "set_in_use", [true])

func _on_VehicleBody_body_entered(body):
	pass

func _on_Vehicle_body_entered(body):
	if body.has_method("physics_object"):
		body.queue_free()

func _on_Area_body_entered(body):
	if velocity.length() < 15:
		return 
	if body.has_method("damage") and body != Global.player:
		body.damage(200, (global_transform.origin - body.global_transform.origin).normalized(), body.global_transform.origin, global_transform.origin)

remote func _set_master(id):
	#set_network_master(id)
	pass
