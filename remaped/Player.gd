extends KinematicBody

var G_CHEST = preload("res://Entities/Physics_Objects/Chest_Gib.tscn")
var G_LEG = preload("res://Entities/Physics_Objects/Leg_Gib.tscn")
var G_ARM = preload("res://Entities/Physics_Objects/Arm_Gib.tscn")
var G_HEAD = preload("res://Entities/Physics_Objects/Player_Head_Gib.tscn")

var gibs = [G_CHEST,G_LEG,G_ARM,G_HEAD]

var EXPLOSION = preload("res://Entities/Bullets/Self_Destruct_Explosion.tscn")
var VOMIT = preload("res://Entities/Decals/FleshDecal2.tscn")
var stair = true
var toxic = false
var disabled = false
var delta_accumulator = 0
var orb = true
var drugged = false
var drug_speed = 0
var drug_slowfall = 0
var drug_gravity_flag = false
var thrust_kills:Array
var last_time = 0
var current_time = 0
var lean_amount = 0.5
var hazmat = false
var grapple_orb = preload("res://Entities/grappleorb.tscn")
var grapple_orbs:Array
var helmet_flag = false
var toxic_damage_count = 0
var local_money = 0
var in_air = false
var last_wall_norm = Vector3.ZERO
var jump_bonus = 0
var double_jump_flag = 0
var start_flag = false
onready var psychosound = $Soundrotator / Psychosound
var special_vision = true
var last_height = Vector3.ZERO
var foot_step_counter = 0
var top_touching = false
var crouch_flag = false
var grav_reverse = false
onready var curse_torch = $Curse_Torch
onready var body_mesh = $Body_Mesh / AnimationPlayer
export  var interpolated_camera = false

var friction_disabled = false

onready var audio_player = $AudioStreamPlayer3D
var ambient_color
var ambient_energy
var lean = 0
onready var UI = $UI
onready var reticle = $Reticle
var player_view:Camera
var rotation_helper
var x_mouse_sensitivity = 0.1
var y_mouse_sensitivity = 0.1
onready var crush_check = $Crush_Check / CollisionShape
onready var collision_box = $CollisionShape
onready var crush_checker = $Crush_Check
var on_floor = false
var on_wall = false
var on_slope = false

var health = 100
export  var max_gravity = 22
export  var gravity = 22
var gravity_modifier = 1
export  var friction = 6

export  var move_speed = 9
var speed_bonus = 0
var armor:float = 0
export  var base_move_speed = 9
export  var run_acceleration = 10
export  var run_deacceleration = 10
export  var air_acceleration = 2
export  var air_deacceleration = 20
export  var air_control = 2
export  var side_strafe_acceleration = 0.06
export  var side_strafe_speed = 0.06
export  var jump_speed = 8
export  var regular_jump_speed = 8
export  var water_speed = 4
var hold_jump_to_bhop = false
onready var terrorsuit = $Terrorsuit
var move_direction = Vector3(0, 0, 0)
var move_direction_norm = Vector3(0, 0, 0)
var player_velocity = Vector3(0, 0, 0)
var player_top_velocity = 0

onready var aim_point = $Aim_Point

var wish_jump = false
var collision
var key_found = false
var player_friction = 0
var water = false
var ladder = false
var dead = false
var died = false

var pain_sound
var psychocounter = 0
class Cmd:
	var forward_move:float
	var right_move:float
	var up_move:float
var snap_variable = 1
var cmd
var weapon
var grab_hand
var rotate_towards = 0
var move_towards_z = 0
var move_towards_y = 0
var GLOBAL
var time = 1
var time_2 = 0
var amp = 1
var last_player_velocity_y = 0
var forward_room_pos:Vector3
var back_room_pos:Vector3
var left_room_pos:Vector3
var psychosis:bool = false
var right_room_pos:Vector3
var shader_screen
var ray_rotation
var front_pos_helper
var floor_ray
var floor_ray2
var jump_counter = 0
var cancer_count = 0

var on_ceiling = false
var r

################################################################################

remote func _spawn_gib(gib,gibName,gibPos,recivedDamage):
	var new_gib = gibs[gib].instance()
	new_gib.set_name(gibName)
	get_tree().get_nodes_in_group("Sync")[0].add_child(new_gib)
	new_gib.global_transform.origin = gibPos
	new_gib.damage(recivedDamage[0], recivedDamage[1], recivedDamage[2], recivedDamage[3])

remote func _play_sound(soundName):
	var netId = get_tree().get_rpc_sender_id()
	get_tree().get_nodes_in_group("Multiplayer")[0].player_info[netId].puppet.get_node("Puppet/PlayerModel/SFX/" + soundName).play()

remote func _play_death_sound():
	get_tree().get_nodes_in_group("Multiplayer")[0].player_info[get_tree().get_rpc_sender_id()].puppet.play_death_sound()

remote func _spawn_explosion(pos):
	if get_tree().get_network_unique_id() != get_tree().get_rpc_sender_id():
		var n_explosion = preload("res://MOD_CONTENT/CruS Online/effects/fake_self_destruct_explosion.tscn").instance()
		get_parent().add_child(n_explosion)
		n_explosion.global_transform.origin = pos
		
		get_tree().get_nodes_in_group("Multiplayer")[0].player_info[get_tree().get_rpc_sender_id()].puppet.play_explosion_sound()

################################################################################

func _enter_tree():
	name = "Player"
	GLOBAL = Global
	GLOBAL.player = self
	GLOBAL.objective_complete = false
	GLOBAL.objectives = 0

var death_timer
	
func cancer():
	UI.notify("Your body feels weird.", Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1)))
	cancer_count += 1
	if cancer_count == 10:
		weapon.disabled = true
		weapon.hide()
		speed_bonus = - 10
		set_move_speed()

func _ready():
	death_timer = Timer.new()
	add_child(death_timer)
	death_timer.wait_time = 5
	death_timer.one_shot = true
	death_timer.connect("timeout", self, "instadie")
	
	current_time = OS.get_system_time_msecs()
	last_time = OS.get_system_time_msecs()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), Global.music_volume)
	if GLOBAL.CURRENT_LEVEL == 18 and Global.DEAD_CIVS.find("Limit Chancellor") == - 1:
		Global.implants.head_implant = Global.implants.empty_implant
		Global.implants.torso_implant = Global.implants.empty_implant
		Global.implants.leg_implant = Global.implants.empty_implant
		Global.implants.arm_implant = Global.implants.empty_implant
		UI.notify("A malign influence strips you of power.", Color(0, 0, 1))
		Global.menu.get_node("Character_Menu/Character_Container").clear_equips()
		Global.menu.get_node("Character_Menu/Character_Container").update_buttons()
	if not GLOBAL.implants.head_implant.nightmare and not GLOBAL.implants.head_implant.nightvision:
		$NV.queue_free()
	if Global.implants.torso_implant.orbsuit:
		orb = true
	else :
		orb = false
	get_parent().get_node("Position3D/Rotation_Helper/Water_Check").connect("area_entered", self, "_on_Water_Check_area_entered")
	get_parent().get_node("Position3D/Rotation_Helper/Water_Check").connect("area_exited", self, "_on_Water_Check_area_exited")
	terrorsuit.rect_scale.x = GLOBAL.resolution[0] / 1280
	terrorsuit.rect_scale.y = GLOBAL.resolution[1] / 720
	health *= get_parent().scale.x
	UI.set_health(health)
	last_height = global_transform.origin.y

	pain_sound = $Pain
	ray_rotation = $Ray_Rotation
	floor_ray = $Ray_Rotation / Floor_Ray
	floor_ray2 = $Ray_Rotation / Floor_Ray2
	shader_screen = $Shader_Screen
	if Global.implants.head_implant.nightvision:
		$NV.show()
		shader_screen.material.set_shader_param("scope", true)
	r = Global.status()

	
	if not GLOBAL.implants.arm_implant.radio:
		if GLOBAL.LEVEL_AMBIENCE[GLOBAL.CURRENT_LEVEL] != null:
			GLOBAL.ambience.stream = GLOBAL.LEVEL_AMBIENCE[GLOBAL.CURRENT_LEVEL]
			GLOBAL.ambience.play()

	grab_hand = $Grab_Hand
	grab_hand.rect_position = Vector2(GLOBAL.resolution[0] / 2, GLOBAL.resolution[1] / 2)
	if interpolated_camera:
		player_view = get_parent().get_node("Position3D/Rotation_Helper/Camera")
		rotation_helper = get_parent().get_node("Position3D/Rotation_Helper")
		weapon = rotation_helper.get_node("Weapon")
	else :
		player_view = $Rotation_Helper / Camera
		weapon = $Rotation_Helper / Weapon
		rotation_helper = $Rotation_Helper
	player_view.fov = GLOBAL.FOV
	front_pos_helper = weapon.get_node("Front_Pos_Helper")
	
	if GLOBAL.rain:
		shader_screen.material.set_shader_param("rain", true)
	else :
		shader_screen.material.set_shader_param("rain", false)
	if GLOBAL.implants.head_implant.nightmare:
		$NV.show()
		shader_screen.material.set_shader_param("nightmare_vision", true)
	if GLOBAL.implants.head_implant.holy:
		shader_screen.material.set_shader_param("holy_mode", true)
	if Global.rain and (Global.menu.weapon_1 == weapon.W_ROD or Global.menu.weapon_2 == weapon.W_ROD):
		GLOBAL.music.stream = load("res://Sfx/Music/rain.ogg")
	else :
		GLOBAL.music.stream = GLOBAL.LEVEL_SONGS[GLOBAL.CURRENT_LEVEL]
	
	if not GLOBAL.implants.arm_implant.radio:
		GLOBAL.music.play()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(false)
	cmd = Cmd.new()
	shader_screen.material.set_shader_param("amplitude", amp)
	shader_screen.material.set_shader_param("intro", true)
	$SFX / Intro_Laugh.play()
	var leg_implant = GLOBAL.implants.leg_implant
	var arm_implant = GLOBAL.implants.arm_implant
	var head_implant = GLOBAL.implants.head_implant
	var torso_implant = GLOBAL.implants.torso_implant
	
	jump_bonus = leg_implant.jump_bonus + torso_implant.jump_bonus + head_implant.jump_bonus + arm_implant.jump_bonus
	if orb:
		health = 200
		UI.set_health(health)
		jump_bonus += 3
		speed_bonus += 1
		$Foot_Step.stream = load("res://Sfx/orbwalk.wav")
	speed_bonus = leg_implant.speed_bonus + torso_implant.speed_bonus + head_implant.speed_bonus + arm_implant.speed_bonus
	if GLOBAL.husk_mode:
		speed_bonus += 0.25
	if Global.death:
		speed_bonus += 0.1
	armor = leg_implant.armor * torso_implant.armor * head_implant.armor * arm_implant.armor
	print("armor", armor)
	if leg_implant.toxic_shield or torso_implant.toxic_shield or arm_implant.toxic_shield or head_implant.toxic_shield or orb:
		hazmat = true
	set_move_speed()
	psychosis = psychocounter > 15
	if GLOBAL.implants.arm_implant.cursed_torch:
		GLOBAL.set_hope()
	if GLOBAL.implants.torso_implant.terror:
		terrorsuit.show()
		UI.hide()
		shader_screen.material.set_shader_param("scope", true)
	if GLOBAL.hope_discarded:
		GLOBAL.music.pitch_scale = 0.75
	else :
		GLOBAL.music.pitch_scale = 1
	
	yield (get_tree(), "idle_frame")
	if Global.CURRENT_LEVEL == 18:
		Global.objective_complete = true
		Global.objectives = 0
	set_move_speed()
	
func set_psychosis(value):
	psychocounter += 1

func thrust():
	print((global_transform.origin - front_pos_helper.global_transform.origin).normalized() * Vector3(1, 0, 1))
	print("FUCK", (global_transform.origin - front_pos_helper.global_transform.origin).normalized() * Vector3(1, 0, 1) * get_process_delta_time() * 60)
	player_velocity -= (global_transform.origin - front_pos_helper.global_transform.origin).normalized() * Vector3(1, 0, 1) * get_process_delta_time() * 60
	$Gunksound.play()
	var space = get_world().direct_space_state
	var result = space.intersect_ray(global_transform.origin + Vector3.UP, global_transform.origin + Vector3.DOWN * 10, [self])
	if result:
		var new_vomit = VOMIT.instance()
		result.collider.add_child(new_vomit)
		new_vomit.global_transform.origin = result.position
		new_vomit.rotation.y = rand_range( - PI, PI)
	
func grapple(pos3d:Position3D):
	var point = pos3d.global_transform.origin
	var distance = global_transform.origin.distance_to(point)
	var orb_res = 4
	if grapple_orbs.size() < int(distance) * orb_res:
		for i in range(orb_res):
			var new_grapple_orb = grapple_orb.instance()
			add_child(new_grapple_orb)
			grapple_orbs.append(new_grapple_orb)
	elif grapple_orbs.size() > int(distance) * orb_res:
		for i in range(orb_res):
			grapple_orbs[grapple_orbs.size() - 1].queue_free()
			grapple_orbs.pop_back()
	for o in grapple_orbs:
		var o_scale = (sin(time * 2 - grapple_orbs.find(o)) * 0.5 + 2) * 0.5
		o.scale = Vector3(o_scale, o_scale, o_scale)
		o.global_transform.origin = global_transform.origin - (global_transform.origin - point).normalized() * grapple_orbs.find(o) / orb_res
	if distance > 3 and distance < 10:
		player_velocity -= (global_transform.origin - point).normalized() * gravity * get_process_delta_time() * 2.3
	elif distance > 10 and distance < 20:
		player_velocity -= (global_transform.origin - point).normalized() * gravity * get_process_delta_time() * 0.7 * 2.3
	elif distance > 20:
		player_velocity -= (global_transform.origin - point).normalized() * gravity * get_process_delta_time() * 2 * 2.3
	
func set_move_speed():
	move_speed = base_move_speed + speed_bonus + drug_speed
	if float(lean) != 0:
		move_speed -= 5
	if crouch_flag:
		move_speed -= 3
	if weapon.weapon1 != null:
		move_speed -= weapon.weight[weapon.weapon1]
	else :
		pass
		
	if weapon.weapon2 != null:
		move_speed -= weapon.weight[weapon.weapon2]
	else :
		pass
	if move_speed < 5:
		run_acceleration = 15
	else :
		run_acceleration = 10
		
	move_speed = clamp(move_speed, 2, 100)
	
func _physics_process(delta):
	drugged = (drug_slowfall > 0 or drug_speed > 0)
	if drugged:
		shader_screen.material.set_shader_param("drugs", true)
	else :
		shader_screen.material.set_shader_param("drugs", false)
	if GLOBAL.implants.head_implant.slowfall or drug_slowfall > 0:
		player_velocity.y = clamp(player_velocity.y, - 3, 100000)
		if drug_slowfall > 0:
			drug_slowfall -= 10 * delta
	if start_flag:
		UI.time_now = OS.get_system_time_msecs()
		current_time = OS.get_system_time_msecs()
		Global.play_time += current_time - last_time
		last_time = current_time
	else :
		current_time = OS.get_system_time_msecs()
		last_time = OS.get_system_time_msecs()
	if Global.implants.head_implant.climb:
		if is_on_wall():
			ladder = true
		else :
			ladder = false
	if dead:
		$SFX / IED1.stop()
		$SFX / IED2.stop()
		$SFX / IED_alert.stop()
		$SFX / IED_alert.pitch_scale = 1
		
		if not is_equal_approx(shader_screen.material.get_shader_param("hit_red"), 0.5):
			shader_screen.material.set_shader_param("hit_red", lerp(shader_screen.material.get_shader_param("hit_red"), 0.5, 0.05))
	else :
		if not is_zero_approx(shader_screen.material.get_shader_param("hit_red")):
			shader_screen.material.set_shader_param("hit_red", lerp(shader_screen.material.get_shader_param("hit_red"), 0, 0.1))
	if disabled:
		return 
	if not is_on_floor():
		
		body_mesh.play("Jump")
	elif Vector2(player_velocity.x, player_velocity.z).length() > 0.1:
		body_mesh.play("Run")
	else :
		body_mesh.play("Idle")
	terrorsuit.rect_scale.x = GLOBAL.resolution[0] / 1280
	terrorsuit.rect_scale.y = GLOBAL.resolution[1] / 720
	psychosis = psychocounter > 5
	psychocounter -= 0.2
	psychocounter = clamp(psychocounter, 0, 25)
	if psychosis and not dead and not died:
		$Soundrotator.rotation.y += delta
		player_view.h_offset = sin(time) * 0.2
		if cos(time) > 0:
			weapon.AI_shoot()
		if not psychosound.playing:
			psychosound.play()
		psychosound.pitch_scale += delta * 0.1
		psychosound.pitch_scale = wrapf(psychosound.pitch_scale, 0.3, 1.3)
		player_view.fov -= 1
		player_view.fov = wrapf(player_view.fov, 4, 120)
		rotation_helper.rotation.x += sin(time_2 * 0.1) * 0.01
		rotation.y += cos(time_2 * 0.08) * 0.01
	elif psychosound.playing:
		psychosound.stop()
	else :
		if is_instance_valid(player_view) and not is_zero_approx(player_view.h_offset):
			player_view.h_offset = lerp(player_view.h_offset, 0, 0.5)
	time_2 += 1
	if grab_hand.visible:
		grab_hand.rect_position = Vector2(GLOBAL.resolution[0] / 2, GLOBAL.resolution[1] / 2)
	if toxic:
		rotation_helper.rotation.x += sin(time_2 * 0.1) * 0.01
		rotation.y += cos(time_2 * 0.08) * 0.01
	if drug_speed > 0:
		drug_speed -= 7 * delta
		set_move_speed()
	if fmod(time_2, 40) == 0 and toxic:
		var tox_damage = 20
		if GLOBAL.punishment_mode:
			tox_damage *= 0.25
		if GLOBAL.soul_intact or GLOBAL.hope_discarded:
			tox_damage *= 0.5
		damage(tox_damage, Vector3.ZERO, global_transform.origin, global_transform.origin)
		toxic_damage_count += 1
		if toxic_damage_count == 9:
			toxic = false
			UI.toxic = false
			toxic_damage_count = 0
			set_move_speed()
	amp -= delta * 0.5
	if amp >= 0:
		shader_screen.material.set_shader_param("amplitude", amp)
	if amp < 0:
		if not start_flag:
			shader_screen.material.set_shader_param("intro", false)
			set_process_input(true)
			start_flag = true
	else :
		player_velocity.x = 0
		player_velocity.z = 0
	if GLOBAL.implants.arm_implant.cursed_torch:
		curse_torch.show()
		curse_torch.light_energy = (sin(time) + 1.2) * 0.5
	if Input.is_action_just_pressed("Vision") and GLOBAL.debug:
		special_vision = not special_vision
		if GLOBAL.implants.head_implant.nightmare:
			shader_screen.material.set_shader_param("nightmare_vision", special_vision)
		if GLOBAL.implants.head_implant.holy:
			shader_screen.material.set_shader_param("holy_mode", special_vision)
	if Input.is_action_just_pressed("crouch") or cancer_count >= 10:
		if $Top_Checkr / RayCast.is_colliding():
			top_touching = true
		else :
			top_touching = false
		if (top_touching and crouch_flag):
			return 
		crouch_flag = not crouch_flag
		if cancer_count >= 10:
			crouch_flag = true
		if crouch_flag:
			if max_gravity > 0:
				rotation_helper.transform.origin.y = - 0.2
			else :
				rotation_helper.transform.origin.y = 0.2
			$CollisionShape.disabled = true
			floor_ray.cast_to.y = - 0.05
			floor_ray2.cast_to.y = - 0.05
			$CrouchCollision.disabled = false
			$Crush_Check / CollisionShape.disabled = true
			$Crush_Check / CrouchCrush.disabled = false
			set_move_speed()
		elif not top_touching:
			translate(Vector3.UP * 0.5 * sign(max_gravity))
			$CollisionShape.disabled = false
			floor_ray.cast_to.y = - 0.8
			floor_ray2.cast_to.y = - 0.8
			$CrouchCollision.disabled = true
			run_acceleration = 10
			$Crush_Check / CollisionShape.disabled = false
			$Crush_Check / CrouchCrush.disabled = true
			rotation_helper.transform.origin.y = 0
			set_move_speed()
	if toxic and not crouch_flag:
		move_speed = 7 + sin(time_2)
	if Input.is_action_pressed("Lean_Left"):
		lean = - 1
		set_move_speed()
	elif Input.is_action_pressed("Lean_Right"):
		lean = 1
		set_move_speed()
	else :
		lean = 0
	if Input.is_action_just_released("Lean_Left") or Input.is_action_just_released("Lean_Right"):
		lean = 0
		set_move_speed()
	if Input.is_action_just_pressed("Suicide"):
		suicide()
	time += delta
	if died:
		$SFX / IED_alert.pitch_scale += 0.1
		$SFX / IED1.pitch_scale = sin(time * rand_range(0, 2.5)) * rand_range(0.1, 0.3) + 1.1
		$SFX / IED2.pitch_scale = sin(time * rand_range(0, 5)) * 0.3 + 1.1
	x_mouse_sensitivity = GLOBAL.mouse_sensitivity
	y_mouse_sensitivity = GLOBAL.mouse_sensitivity
	if GLOBAL.camera_sway and max_gravity > 0:
		rotate_towards -= player_velocity.length() * cmd.right_move * 0.01
		rotate_towards = clamp(rotate_towards, deg2rad( - 4), deg2rad(4))
		rotate_towards *= 0.9
	move_towards_z -= player_velocity.length() * cmd.forward_move * 0.01
	move_towards_z = clamp(move_towards_z, deg2rad( - 1), deg2rad(1))
	move_towards_z *= 0.9
	move_towards_y = clamp(0.025 + player_velocity.y * 0.01, 0.02, 0.025)
	if not dead:
		if not is_equal_approx(player_view.transform.origin.z, move_towards_z):
			player_view.transform.origin.z = lerp(player_view.transform.origin.z, move_towards_z, 0.2)
		if not is_equal_approx(player_view.transform.origin.y, move_towards_y):
			player_view.transform.origin.y = lerp(player_view.transform.origin.y, move_towards_y, 0.2)
	shader_screen.material.set_shader_param("health_green", lerp(shader_screen.material.get_shader_param("health_green"), 0, 0.1))
	move(delta)

func detox():
	toxic = false
	UI.toxic = false
	toxic_damage_count = 0
	set_move_speed()

func _process(delta):
	if (Input.is_action_just_pressed("Tertiary_Weapon") and Global.implants.arm_implant.grav and cancer_count < 10) or drug_gravity_flag == true:
		max_gravity *= - 1
		$Top_Checkr / RayCast.cast_to *= - 1
		stair = not stair
		rotation_helper.rotation.x *= - 1
		if max_gravity > 0:
			get_parent().cam_pos.rotation.z = deg2rad(0)
			if crouch_flag:
				rotation_helper.transform.origin.y = - 0.2
		else :
			get_parent().cam_pos.rotation.z = deg2rad(180)
			if crouch_flag:
				rotation_helper.transform.origin.y = - 0.7
		drug_gravity_flag = false
	queue_jump()

func suicide():
	if not died:
		health = 0
		UI.set_health(health)
		die(100, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)
	elif not dead:
			instadie(100, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)

func move(delta):
	
	
	
	var floor_normal
	var on_floor = is_on_floor()
	if Vector3(cmd.right_move, 0, cmd.forward_move).length() != 0:
		ray_rotation.look_at(global_transform.origin + Vector3(cmd.right_move, 0, cmd.forward_move), Vector3.UP)
		ray_rotation.transform.basis *= transform.basis
		ray_rotation.transform.basis = ray_rotation.transform.basis.orthonormalized()
	if stair == true and is_on_floor():
		if floor_ray.get_collision_normal().y > 0.99 and floor_ray.is_colliding():
			
			global_transform.origin.y = floor_ray.get_collision_point().y
			
		if floor_ray2.get_collision_normal().y > 0.99 and floor_ray2.is_colliding():
			
			global_transform.origin.y = floor_ray2.get_collision_point().y
			
	
	if not on_floor:
		if not in_air or player_velocity.y > 0:
			var glob = global_transform.origin.y
			last_height = glob
		in_air = true
		if not is_on_ceiling():
			last_player_velocity_y = player_velocity.y
	
		
		

		
	if on_floor or water:
		ground_move(delta)
	elif not on_floor:
		air_move(delta)

	if not water and not ladder:
		jump_speed = regular_jump_speed + jump_bonus
		gravity = max_gravity
	elif not water and ladder:
		
		player_velocity = cmd.forward_move * move_speed / 2 * (global_transform.origin - front_pos_helper.global_transform.origin).normalized()

		jump_speed = water_speed
		gravity = 0
	else :
		player_velocity = cmd.forward_move * move_speed / 2 * (global_transform.origin - front_pos_helper.global_transform.origin).normalized()

		jump_speed = water_speed
		if not Global.high_performance:
			gravity = max_gravity * 2
		else :
			gravity = max_gravity
	

	if dead:
		x_mouse_sensitivity = 0.01
		y_mouse_sensitivity = 0.01
		player_velocity = Vector3(0, player_velocity.y, 0)
	var la = 0.75
	if lean == - 1:
		$LeanRay.cast_to = Vector3(la, 0, 0)
		var col = false
		if $LeanRay.is_colliding():
			col = true
			la = $LeanRay.global_transform.origin.distance_to($LeanRay.get_collision_point()) - 0.2
		player_view.rotation.z = lerp(player_view.rotation.z, deg2rad(45), 1 * delta)
		if not col:
			rotation_helper.translation.x = lerp(rotation_helper.translation.x, la, 5 * delta)
		else :
			rotation_helper.translation.x = la
	elif lean == 1:
		var col = false
		$LeanRay.cast_to = Vector3( - la, 0, 0)
		if $LeanRay.is_colliding():
			col = true
			la = $LeanRay.global_transform.origin.distance_to($LeanRay.get_collision_point()) - 0.2
		player_view.rotation.z = lerp(player_view.rotation.z, deg2rad( - 45), 1 * delta)
		if not col:
			rotation_helper.translation.x = lerp(rotation_helper.translation.x, - la, 5 * delta)
		else :
			rotation_helper.translation.x = - la
	else :
		rotation_helper.translation.x = lerp(rotation_helper.translation.x, 0, 5 * delta)
	
	if on_floor and not Input.is_action_pressed("movement_jump"):
		foot_step_counter += Vector3(player_velocity.x, 0, player_velocity.z).length() * delta
		if foot_step_counter > 4:
			$Foot_Step.pitch_scale = 0.8 + rand_range( - 0.2, 0.2)
			$Foot_Step.play()
			rpc("_play_sound","FootStep")
			foot_step_counter = 0
			if cancer_count > 5:
					var space = get_world().direct_space_state
					var result = space.intersect_ray(global_transform.origin + Vector3.UP, global_transform.origin + Vector3.DOWN * 10, [self])
					if result:
						var new_vomit = VOMIT.instance()
						result.collider.add_child(new_vomit)
						new_vomit.global_transform.origin = result.position
						new_vomit.rotation.y = rand_range( - PI, PI)
						gravity_modifier = 0.01
	else :
		gravity_modifier = 1
	
	player_velocity.y -= gravity * delta
	player_velocity.y *= gravity_modifier
	if is_instance_valid(player_view):
		player_view.rotation.z = lerp(player_view.rotation.z, rotate_towards, 0.2)
	
	if on_floor:
		var floor_ray_normal = Vector3.UP
		if floor_ray.is_colliding():
			floor_ray_normal = floor_ray.get_collision_normal()
		var fnormal = get_floor_normal()
		if fnormal.y < 0.69 and fnormal.y != 0 and floor_ray_normal.y < 0.69 and floor_ray_normal.y > 0:
			player_velocity = player_velocity.length() * Vector3(fnormal.y, fnormal.x + fnormal.z, fnormal.y).normalized()
	
	if not GLOBAL.implants.torso_implant.bouncy:
		if on_floor and last_player_velocity_y < - 18 and abs(global_transform.origin.y - last_height) > 7 and global_transform.origin.y < last_height:
				var fall_damage = - last_player_velocity_y * 9

				if GLOBAL.punishment_mode:
					fall_damage *= 0.25
				if GLOBAL.soul_intact or GLOBAL.hope_discarded:
					fall_damage *= 0.5
				if abs(global_transform.origin.y - last_height) > 40:
					fall_damage = 400
				if orb:
					fall_damage *= 0.25
				damage(fall_damage, Vector3.ZERO, global_transform.origin, global_transform.origin)
				last_player_velocity_y = player_velocity.y
				last_height = global_transform.origin.y
	else :
		if (on_floor or is_on_ceiling()) and abs(last_player_velocity_y) > 5:
				player_velocity.y = last_player_velocity_y * - 0.85
				last_player_velocity_y = player_velocity.y
	if on_floor:
		last_wall_norm = Vector3.ZERO
		in_air = false
	
	var floor_direction = Vector3.DOWN
	var sgn = 1
	if max_gravity > 0:
		floor_direction = Vector3.UP
		sgn = - 1
	elif Global.CURRENT_LEVEL == 18:
			damage(2, Vector3.ZERO, Vector3.ZERO, global_transform.origin)
	var snap = get_floor_normal() * - 1
	if player_velocity.y > 0 and max_gravity > 0:
		snap = Vector3.ZERO
	elif player_velocity.y < 0 and max_gravity < 0:
		snap = Vector3.ZERO
	if is_on_floor() and not Input.is_action_pressed("movement_jump") and not (Global.implants.torso_implant.jetpack and Input.is_action_pressed("kick")):
		player_velocity.y = 0
	player_velocity = move_and_slide_with_snap(player_velocity, snap, floor_direction, false, 4, deg2rad(46), false)

			
	
	var udp = player_velocity
	udp.y = 0.0
	if udp.length() > player_top_velocity:
		player_top_velocity = udp.length()

func set_movement_dir():
	if amp < 0:
		cmd.forward_move = Input.get_action_strength("movement_backward") - Input.get_action_strength("movement_forward")
		cmd.right_move = Input.get_action_strength("movement_right") - Input.get_action_strength("movement_left")
		if max_gravity < 0:
			cmd.right_move *= - 1

func queue_jump():
	if not dead:
		if hold_jump_to_bhop or water:
			wish_jump = Input.is_action_pressed("movement_jump")
			return 
		if Input.is_action_just_pressed("movement_jump") and not wish_jump:
			
			wish_jump = true
		if not Input.is_action_pressed("movement_jump"):
			wish_jump = false

func air_move(delta):
	
	var wishdir
	var wishvel = air_acceleration
	var accel
	apply_friction(0.4, delta)
	set_movement_dir()
	wishdir = Vector3(cmd.right_move, 0, cmd.forward_move)
	wishdir = - get_transform().basis.xform(wishdir)
	
	var wishspeed = wishdir.length()
	wishspeed *= move_speed
	
	wishdir = wishdir.normalized()
	move_direction_norm = wishdir
	
	var wishspeed2 = wishspeed
	if player_velocity.dot(wishdir) < 0:
		accel = air_deacceleration
	else :
		accel = air_acceleration
	
	if cmd.forward_move == 0 and cmd.right_move == 0:
		if wishspeed > side_strafe_speed:
			wishspeed = side_strafe_speed
		accel = side_strafe_acceleration
	
	accelerate(wishdir, wishspeed, accel, delta)
	if air_control:
		air_control(wishdir, wishspeed, delta)
	if (Input.is_action_just_pressed("movement_jump") and double_jump_flag > 0):
		var space = get_world().direct_space_state
		var result = space.intersect_ray(global_transform.origin, global_transform.origin + Vector3.DOWN * 10, [self])
		if result:
			var new_vomit = VOMIT.instance()
			result.collider.add_child(new_vomit)
			new_vomit.global_transform.origin = result.position
		$Gunksound.play()
		$Particles.emitting = true
		player_velocity.y *= 0.5
		var j = jump_speed
		if max_gravity < 0:
			j *= - 1
		player_velocity.y += j
		player_velocity += get_floor_velocity()
		double_jump_flag -= 1
		wish_jump = false
	elif Input.is_action_just_pressed("movement_jump") and is_on_wall() and r:
		var count: = get_slide_count()
		if count != 0:
			var norm = get_slide_collision(0).normal
			var j = jump_speed
			if max_gravity < 0:
				j *= - 1
			if last_wall_norm.angle_to(norm) > deg2rad(100) or last_wall_norm == Vector3.ZERO:
				player_velocity = Vector3(0, j * 1.1, 0) + norm * 15
				last_wall_norm = norm

func air_control(wishdir, wishspeed, delta):
	var zspeed
	var speed
	var dot
	var k
	var i
	
	if cmd.forward_move == 0 or wishspeed == 0:
		return 
	zspeed = player_velocity.y
	player_velocity.y = 0
	
	speed = player_velocity.length()
	player_velocity = player_velocity.normalized()
	
	dot = player_velocity.dot(wishdir)
	k = 32
	k *= air_control * dot * dot * delta
	
	if dot > 0:
		player_velocity.x = player_velocity.x * speed + wishdir.x * k
		player_velocity.y = player_velocity.y * speed + wishdir.y * k
		player_velocity.z = player_velocity.z * speed + wishdir.z * k
		
		player_velocity = player_velocity.normalized()
		move_direction_norm = player_velocity
	
	player_velocity.x *= speed
	player_velocity.y = zspeed
	player_velocity.z *= speed

func ground_move(delta):
	var wishdir
	var wishvel
	double_jump_flag = Global.implants.leg_implant.double_jump

	if not wish_jump:
		apply_friction(1.0, delta)
	else :
		apply_friction(1.0, delta)
		
	set_movement_dir()
	
	wishdir = Vector3(cmd.right_move, 0, cmd.forward_move)
	wishdir = - get_transform().basis.xform(wishdir)
	wishdir = wishdir.normalized()
	move_direction_norm = wishdir
	
	var wishspeed = wishdir.length()
	wishspeed *= move_speed
	
	accelerate(wishdir, wishspeed, run_acceleration, delta)









	player_velocity.y = 0

	if (wish_jump):
		var jetpack = Input.is_action_pressed("kick") and Global.implants.torso_implant.jetpack
		if jump_bonus > 0 and not water and not jetpack:
			$Boostjump.play()
		elif not water and not jetpack:
			audio_player.play()
		var j = jump_speed
		if jetpack:
			j = 1
		if max_gravity < 0:
			j *= - 1
		player_velocity.y = j
		player_velocity += get_floor_velocity()
		wish_jump = false

func apply_friction(t, delta):
	if GLOBAL.implants.leg_implant.ski or friction_disabled:
		return 
	var vec = player_velocity
	var vel
	var speed
	var newspeed
	var control
	var drop
	
	vec.y = 0.0
	speed = vec.length()
	drop = 0.0
	
	if is_on_floor() or is_on_wall() or water:
	
		
		control = run_deacceleration if speed < run_deacceleration else speed
		drop = control * friction * delta * t
	
	newspeed = speed - drop
	player_friction = newspeed
	if newspeed < 0:
		newspeed = 0
	if speed > 0:
		newspeed /= speed
	
	player_velocity.x *= newspeed
	player_velocity.z *= newspeed

func accelerate(wishdir, wishspeed, accel, delta):
	var addspeed
	var accelspeed
	var currentspeed
	
	currentspeed = player_velocity.dot(wishdir)
	
	addspeed = wishspeed - currentspeed
	if addspeed <= 0:
		return 
	accelspeed = accel * delta * wishspeed
	if accelspeed > addspeed:
		accelspeed = addspeed
	player_velocity.x += accelspeed * wishdir.x
	player_velocity.z += accelspeed * wishdir.z

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if not Input.is_action_pressed("reload"):
			var sensitivity = x_mouse_sensitivity * player_view.fov / Global.FOV
			
			var rot_deg_y = deg2rad(event.relative.y * sensitivity)
			if GLOBAL.invert_y:
				rot_deg_y *= - 1
			rotation_helper.rotate_x(rot_deg_y)
			if max_gravity > 0:
				self.rotate_y(deg2rad(event.relative.x * sensitivity * - 1))
			else :
				self.rotate_y(deg2rad(event.relative.x * sensitivity))
			var camera_rot = rotation_helper.rotation_degrees
			camera_rot.x = clamp(camera_rot.x, - 75, 75)
			rotation_helper.rotation_degrees = camera_rot

func damage(damage, collision_n, collision_p, shooter_pos):
	if dead:
		return 
	if not GLOBAL.punishment_mode:
		damage *= 0.25
	if GLOBAL.soul_intact or GLOBAL.hope_discarded:
		damage *= 2

	damage = damage * armor

	$Reticle.set_shooter_pos((global_transform.origin - shooter_pos).rotated(Vector3(0, 1, 0), - rotation.y))
	player_velocity -= collision_n * damage * 0.2
	if not helmet_flag and GLOBAL.implants.head_implant.helmet and damage < 50:
		if randi() % 2 == 0:
			helmet_flag = true
		$Armorsound.play()
		return 
	if Global.implants.torso_implant.instadeath or Global.implants.head_implant.shrink:
		damage = health
	health -= damage
	
	shader_screen.material.set_shader_param("hit_red", 0.25)
	
	UI.set_health(health)
	if damage > 5:
		pain_sound.play()
		rpc("_play_sound","Pain")
	if health <= 0 and not dead and not died:
		die(damage, collision_n, collision_p, shooter_pos)
	if health < - 40 and not dead:
		instadie(damage, collision_n, collision_p, shooter_pos)

func die(damage, collision_n, collision_p, shooter_pos):
	if died:
		return 
	died = true
	if dead:
		$SFX / IED1.stop()
		$SFX / IED2.stop()
		$SFX / IED_alert.stop()
		return 
	UI.set_death_timer(5)
	$SFX / IED1.play()
	$SFX / IED2.play()
	$SFX / IED_alert.play()
	
	rpc("_play_death_sound")

	death_timer.start()

func instadie(damage = 100, collision_n = Vector3.ZERO, collision_p = Vector3.ZERO, shooter_pos = Vector3.ZERO):
	death_timer.stop()
	if dead:
		$SFX / IED1.stop()
		$SFX / IED2.stop()
		$SFX / IED_alert.stop()
		return 
	dead = true
	died = true
	health = 0
	$SFX / IED1.stop()
	$SFX / IED2.stop()
	$SFX / IED_alert.stop()
	$SFX / IED_explosion.play()
	UI.set_health(health)

	weapon.set_process(false)
	weapon.hide()
	rpc("_spawn_explosion",global_transform.origin)
	var n_explosion = EXPLOSION.instance()
	get_parent().add_child(n_explosion)
	n_explosion.global_transform.origin = global_transform.origin
	spawn_gib(0, 1, damage, collision_n, collision_p)
	spawn_gib(1, 2, damage, collision_n, collision_p)
	spawn_gib(2, 2, damage, collision_n, collision_p)
	spawn_gib(3, 1, damage, collision_n, collision_p)
	UI.hide()
	GLOBAL.get_node('DeathScreen').show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_Crush_Check_body_entered(body):
		if body.get_class() == "StaticBody":
			instadie(2000, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)

func _on_Water_Check_area_entered(area):
	water = true
	AudioServer.set_bus_effect_enabled(1, 0, true)
	
	shader_screen.material.set_shader_param("water", true)

func _on_Water_Check_area_exited(area):
	water = false
	AudioServer.set_bus_effect_enabled(1, 0, false)
	AudioServer.set_bus_effect_enabled(1, 1, false)
	if Input.is_action_pressed("movement_jump"):
		player_velocity.y += jump_speed * 2
	shader_screen.material.set_shader_param("water", false)

func set_ladder(truth):
	ladder = truth

func spawn_gib(gib, count, damage, collision_n, collision_p):
	for i_gib in range(count):
		randomize()
		var randName = int(rand_range(0,1000000))
		var new_gib = gibs[gib].instance()
		new_gib.set_name(new_gib.name + "#" + str(randName))
		get_tree().get_nodes_in_group("Sync")[0].add_child(new_gib)
		new_gib.global_transform.origin = global_transform.origin
		var damageArgs = [damage * 10, - collision_n + Vector3(rand_range(0, 0.1), rand_range(0, 0.1), rand_range(0, 0.1)), collision_p, Vector3.ZERO]
		new_gib.damage(damageArgs[0], damageArgs[1], damageArgs[2], damageArgs[3])
		rpc("_spawn_gib",gib,new_gib.name,new_gib.global_transform.origin,damageArgs)
		return new_gib

func add_health(a_health):
	if health > 0:
		UI.notify(str(a_health) + " health absorbed", Color(1, 0.3, 0.3))
		$SFX / Health.play()
		rpc("_play_sound","Health")
		health += a_health
		if health > 100:
			if not orb:
				health = 100
			else :
				if health > 200:
					health = 200
		UI.set_health(health)
		shader_screen.material.set_shader_param("health_green", 0.5)

func add_ammo(amount, type):
	weapon.add_ammo(amount, type)

func _on_Stair_Check_body_entered(body):
	stair = false

func _on_Stair_Check_body_exited(body):
	stair = true

func get_type():
	return 0

func set_scope(value):
	if value:
		$Scope.show()
	else :
		$Scope.hide()
	if not GLOBAL.implants.torso_implant.terror and not GLOBAL.implants.head_implant.nightvision:
		shader_screen.material.set_shader_param("scope", value)

func _on_Top_Check_body_entered(body):
	top_touching = true

func _on_Top_Check_body_exited(body):
	top_touching = false

func set_toxic():
	if hazmat:
		return 
	toxic = true
	UI.toxic = true
