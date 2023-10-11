extends Spatial
export  var player:bool = false
export  var enemy_accuracy:float = 0.1



enum {W_PISTOL, W_SMG, W_TRANQ, W_BLACKJACK, W_SHOTGUN, W_ROCKET_LAUNCHER, W_SNIPER, W_AR, W_SILENCED_SMG, W_NAMBU, W_GAS, W_MG3, W_AUTOSHOTGUN, W_MAUSER, W_BORE, W_MKR, W_RADIATOR, W_FLASHLIGHT, W_ZIPPY, W_AN94, W_VAG72, W_STEYR, W_CANCER, W_ROD, W_FLAMETHROWER, W_SKS, W_NAILER, W_SHOCK, W_LIGHT}
const W_NAMES = ["10x25mm Subsonic", "9x19mm Corporate", "Animal Tranquilizer", null, "12 Gauge Flechette", "125mm HEAT", "20x124mm AP", "4.73×33mm Caseless", "9x19mm Goreforce", ".38 Suspicious", "50mm Flesh Eater Grenade", "7.62×51mm DU", "12 Gauge Super Auto", "7.62x51mm Executive", "Null", "4.5×26mm MCR", "null", "null", ".22 SR", "5.45×39mm Abyss", "7.62mm Rancid", "5.56×45mm Sabot", "DNA Scrambler", null, "Fuel", "7.62×39mm Financial", "1x45mm Depleted Uranium Nail", "12 Gauge Shockforce", "Thrngnrngnrxnon"]
enum {T_FLESH, T_ENVIRONMENT}
var leaning_modifier = 0
var fishing_hook:KinematicBody
var line_mesh:Mesh
var fish_strength = 0
var radio
var nearby:Array
var reload_sound
var orb = true
var orb_left = false
var IM:ImmediateGeometry
export  var disabled = false
var explosion = preload("res://Entities/Bullets/Small_Explosion.tscn")
var lifemat = preload("res://Materials/W_Arms2_Mat.tres")
var suitmat = preload("res://Materials/W_Arms3_Mat.tres")
export  var accuracy:Array = [0, 0.02, 0, 0, 0.05, 1, 0, 0.01, 0.01, 0, 0, 0.001, 0.05, 0, 0, 0.01, 0, 0, 0.01, 0.01, 0, 0, 0, 0, 0, 0, 0.002, 0.1, 0]
export  var damage:Array = [20, 20, null, null, 20, null, 100, 20, 20, 60, null, 20, 15, 60, null, 10, null, null, 10, 25, 30, 17, null, null, null, 0, 10, 20, 0]
export  var weight:Array = [0, 1, 0, 0, 1, 2, 2, 1, 1, 0, 1, 2, 2, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0, 2, 1, 0, 0, 3]
export  var double_mg = false
export  var RELOAD_TIME:Array = [2, 2, 2, 1, 1, 3, 1.5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
export  var MAX_AMMO:Array = [100, 150, 5, 0, 50, 5, 20, 135, 150, 25, 0, 150, 50, 9, 0, 100, 0, 0, 200, 90, 72, 72, 18, 0, 0, 30, 200, 20, 90]
export  var MAX_MAG_AMMO:Array = [12, 30, 1, 1, 5, 1, 4, 45, 25, 5, 5, 150, 10, 3, 1, 50, 1, 1, 10, 30, 24, 24, 6, 1, 250, 10, 100, 5, 30]
var ammo:Array = [24, 60, 5, 0, 25, 5, 6, 90, 50, 20, 0, 0, 20, 9, 0, 100, 0, 0, 200, 90, 72, 72, 18, 0, 0, 30, 200, 20, 90]
var kicktimer = 51
var kickflag = false
var alert
var laser_dot
var collision_ray
onready var reload_timer = $Reload_Timer
var through_count = 0
var grapple_target
var item_consumed = false
var flash_light_switch = true
var grenade_ammo = 2
var flashlight
var glob
var magazine_ammo:Array = [12, 30, 1, 1, 5, 1, 4, 45, 25, 5, 5, 150, 10, 3, 1, 50, 1, 1, 10, 30, 24, 24, 6, 1, 250, 10, 100, 5, 30]
const SHELLS = [preload("res://Entities/Physics_Objects/Generic_Shell.tscn"), 
				preload("res://Entities/Physics_Objects/Generic_Shell.tscn"), 
				null, 
				null, 
				preload("res://Entities/Physics_Objects/Shell.tscn"), 
				null, 
				preload("res://Entities/Physics_Objects/20_mm_shell.tscn"), 
				null, 
				preload("res://Entities/Physics_Objects/Generic_Shell.tscn"), 
				preload("res://Entities/Physics_Objects/Generic_Shell.tscn"), 
				preload("res://Entities/Physics_Objects/Generic_Shell.tscn"), 
				preload("res://Entities/Physics_Objects/Generic_Shell.tscn"), 
				preload("res://Entities/Physics_Objects/Shell.tscn"), 
				preload("res://Entities/Physics_Objects/Generic_Shell.tscn"), 
				null, 
				null, 
				null, 
				null, 
				preload("res://Entities/Physics_Objects/Generic_Shell.tscn"), 
				preload("res://Entities/Physics_Objects/Generic_Shell.tscn"), 
				null, 
				preload("res://Entities/Physics_Objects/Generic_Shell.tscn"), 
				preload("res://Entities/Physics_Objects/DNA_shell.tscn"), 
				null, 
				preload("res://Entities/Physics_Objects/Generic_Shell.tscn"), 
				preload("res://Entities/Physics_Objects/Generic_Shell.tscn"), 
				null, 
				preload("res://Entities/Physics_Objects/Shell.tscn"), 
				null]
const IDLE_ANIM:Array = ["Pistol_Idle", "SMG_Idle", "Pistol_Idle", "Baton_Idle", "Shotgun_Idle", "Rocket_Launcher_Idle", "Sniper_Idle", "AR_Idle", "S_SMG_idle", "Nambu_Idle", "Gas_Idle", "MG3_Idle", "Autoshotgun_Idle", "Mauser_Idle", "Bore_Idle", "AR_Idle", "AR_Idle", "Flashlight_Idle", "Pistol_Idle", "AR_Idle", "Pistol_Idle", "AR_Idle", "Pistol_Idle", "Baton_Idle", "AR_Idle", "Shotgun_Idle", "Pistol_Idle", "Pistol_Idle", "Nogun"]
const FIRE_ANIM:Array = ["Pistol_Fire", "SMG_Fire", "Pistol_Fire", "Baton_Fire", "Shotgun_Fire", "Rocket_Launcher_Fire", "Sniper_Fire", "AR_Fire", "S_SMG_fire", "Nambu_Fire", "Gas_Fire", "MG3_Fire", "Autoshotgun_Fire", "Mauser_Fire", "Bore_Idle", "AR_Fire", "AR_Idle", "Flashlight_Idle", "Pistol_Fire", "AR_Fire", "Pistol_Fire", "AR_Fire", "Pistol_Fire", "Baton_Fire", "AR_Idle", "Shotgun_Fire", "Pistol_Fire", "Pistol_Fire", "Nogun"]
const DECALS:Array = [preload("res://Entities/Decals/Decal.tscn"), 
				preload("res://Entities/Decals/Decal.tscn"), 
				null, 
				null, 
				preload("res://Entities/Decals/Flechette.tscn"), 
				preload("res://Entities/Decals/Decal.tscn"), 
				preload("res://Entities/Decals/Flechette.tscn"), 
				preload("res://Entities/Decals/Decal.tscn"), 
				preload("res://Entities/Decals/Decal.tscn"), 
				preload("res://Entities/Decals/Decal.tscn"), 
				null, 
				preload("res://Entities/Decals/Decal.tscn"), 
				preload("res://Entities/Decals/Flechette.tscn"), 
				preload("res://Entities/Decals/Decal.tscn"), 
				null, 
				preload("res://Entities/Decals/Decal.tscn"), 
				null, 
				null, 
				preload("res://Entities/Decals/Decal.tscn"), 
				preload("res://Entities/Decals/Decal.tscn"), 
				preload("res://Entities/Decals/Decal.tscn"), 
				preload("res://Entities/Decals/Flechette.tscn"), 
				preload("res://Entities/Decals/DNA_Decal.tscn"), 
				null, 
				null, 
				preload("res://Entities/Decals/Decal.tscn"), 
				preload("res://Entities/Decals/Nail.tscn"), 
				preload("res://Entities/Decals/Flechette.tscn"), 
				null]
const BULLETS = preload("res://Entities/Bullets/Missile_Kinematic.tscn")
const LIGHT_BULLET = preload("res://Entities/Bullets/Light_Bullet.tscn")
const FIRE = preload("res://Entities/Bullets/Fire.tscn")
const RADIATION = preload("res://Entities/Bullets/Radiation.tscn")
const GRENADE = preload("res://Entities/Bullets/Explosive_Grenade.tscn")
const FLECHETTE_GRENADE = preload("res://Entities/Bullets/Flechette_Grenade.tscn")
const SLEEP_GRENADE = preload("res://Entities/Bullets/Sleep_Grenade.tscn")
const GAS_GRENADE = preload("res://Entities/Bullets/Grenade.tscn")
const BORE = preload("res://Entities/Bullets/New_Bore.tscn")
const HOOK = preload("res://Entities/Physics_Objects/Fishing_Hook.tscn")
const TRANQ_DART = preload("res://Entities/Bullets/tranquilizer_dart.tscn")
const RADIO = preload("res://Entities/Physics_Objects/radio.tscn")
var recoil = 0
var audio
onready var timer:Timer = $Timer
onready var raycast:RayCast = $RayCast
var anim:AnimationPlayer
var UI:Control
var initpos:Vector3
var initrot:Vector3
var t:float = 1
var player_weapon
var held_object

var IM2

var held_object_world = false
var holding = false
var hold_pos
var raycast_init_rot:Vector3
export  var current_weapon = 0
var P_BLOOD = preload("res://Entities/Particles/Blood_Particle.tscn")
var P_SPARK = preload("res://Entities/Particles/Spark_2.tscn")
var P_BLOOD_2 = preload("res://Entities/Particles/Blood_Particle3.tscn")
var P_SNIPER = preload("res://Entities/Particles/Tracer_1.tscn")
var P_SNIPER2 = preload("res://Entities/Particles/Tracer_2.tscn")
var weapon_drop = preload("res://Entities/Objects/Gun_Pickup.tscn")
var shotcount = 0
var zoom_flag = false
var weapon_mesh_z = 0.312
var laser_ray
var weapon1
var weapon2
var held_weapon = 1
var scope_mat:SpatialMaterial
var scope_camera:Camera
var AR_mesh
var MKR_mesh
var RAD_mesh
var AN94_mesh
var PISTOL_mesh
var ZIPPY_mesh
var VAG72_mesh
var ROD_mesh
var BATON_mesh
var DNA_mesh
var STEYR_mesh
var DART_mesh
var SHOTGUN_mesh
var LIGHT_mesh
var SKS_mesh
var RAD_light
var AR_dot
var FT_mesh
var NAILER_mesh
var SHOCK_mesh
var left_arm_mesh
var right_arm_mesh
var muzzle_light
var left_weapon
var leaning
var cylinder_velocity = 0
var radiation_mesh
var radiation_cylinder
var player_muzzle_flash
var use_ray
var orb_anim
var blackjacktimer:Timer
var regentimer1:Timer
var regentimer2:Timer
var grapple_point = Vector3.ZERO
var grapple_flag = false
var melee = false

########################################
# Островок спокойствия

remote func _create_drop_weapon(recivedTransform,recivedHoldPos,implantThrowBonus,recivedCurrentWeapon,recivedAmmo,playerVelocity,recivdeRandName):
	var new_weapon_drop = weapon_drop.instance()
	new_weapon_drop.set_name(new_weapon_drop.name + "#" + str(recivdeRandName))
	get_tree().get_nodes_in_group("Sync")[0].add_child(new_weapon_drop)
	new_weapon_drop.global_transform.origin = recivedTransform
	new_weapon_drop.gun.MESH[new_weapon_drop.gun.current_weapon].hide()
	new_weapon_drop.gun.current_weapon = recivedCurrentWeapon
	new_weapon_drop.gun.ammo = recivedAmmo
	new_weapon_drop.rotation.y = rand_range( - PI, PI)
	new_weapon_drop.velocity -= (20 + implantThrowBonus) * (recivedTransform - recivedHoldPos).normalized()
	new_weapon_drop.velocity += playerVelocity
	new_weapon_drop.gun.MESH[recivedCurrentWeapon].show()

remote func _spawn_object(recivedObject,recivedName,recivedTransform):
	var newObject = load(recivedObject).instance()
	newObject.set_name(recivedName)
	get_tree().get_nodes_in_group("Sync")[0].add_child(newObject)
	newObject.global_transform = recivedTransform

remote func _play_sound(soundName):
	var netId = get_tree().get_rpc_sender_id()
	get_tree().get_nodes_in_group("Multiplayer")[0].player_info[netId].puppet.get_node("Puppet/PlayerModel/SFX/" + soundName).play()

########################################

func _ready()->void :
	glob = Global
	if not player:
		if Global.implants.head_implant.shrink:
			enemy_accuracy *= 0.2
		set_process_input(false)
		
		set_physics_process(false)
		translation.z = 0
		if current_weapon >= W_BLACKJACK:
			current_weapon += 1
	leaning = Input.is_action_pressed("Lean_Left") or Input.is_action_pressed("Lean_Right")
	muzzle_light = get_node_or_null("OmniLight")
	if player:
		if Global.implants.torso_implant.orbsuit:
			orb = true
		else :
			orb = false
		if not orb:
			$orbarms.queue_free()
		line_mesh = Mesh.new()
		IM = $ImmediateGeometry
		flashlight = $Player_Weapon / Flashlight
		blackjacktimer = Timer.new()
		alert = $Alert
		alert.connect("body_entered", self, "alert_body_entered")
		alert.connect("body_exited", self, "alert_body_exited")
		add_child(blackjacktimer)
		blackjacktimer.wait_time = 0.5
		blackjacktimer.one_shot = true
		blackjacktimer.connect("timeout", self, "blackjack_timeout")
		RAD_light = $Radiation_Light
		collision_ray = $Collision_Ray
		collision_ray.add_exception(glob.player)
		hold_pos = get_node_or_null("Object_Hold_Pos")
		anim = $Player_Weapon / AnimationPlayer
		orb_anim = $orbarms / AnimationPlayer
		
		
		AR_mesh = get_node_or_null("Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 9/AR")
		AR_dot = get_node_or_null("Player_Weapon/AR_dot")
		left_arm_mesh = get_node_or_null("Player_Weapon/Player_Weapon/Skeleton/Left_Arm")
		right_arm_mesh = get_node_or_null("Player_Weapon/Player_Weapon/Skeleton/Right_Arm")
		if glob.implants.torso_implant.stealth:
			left_arm_mesh.material_override = load("res://Materials/seethrough.tres")
			right_arm_mesh.material_override = load("res://Materials/seethrough.tres")
		elif Global.implants.torso_implant.instadeath:
			left_arm_mesh.material_override = suitmat
			right_arm_mesh.material_override = suitmat
		elif Global.ending_2:
			left_arm_mesh.material_override = lifemat
			right_arm_mesh.material_override = lifemat
		player_weapon = $Player_Weapon
		AR_mesh.set_layer_mask_bit(0, 0)
		reload_sound = $Reload
		laser_dot = $Laser_Dot
		VAG72_mesh = get_node_or_null("Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 4/Vag72")
		DNA_mesh = get_node_or_null("Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 4/Dna")
		AN94_mesh = get_node_or_null("Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 9/AN94")
		MKR_mesh = get_node_or_null("Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 9/MKR")
		RAD_mesh = get_node_or_null("Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 9/RADGUN")
		STEYR_mesh = get_node_or_null("Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 9/STEYR")
		FT_mesh = get_node_or_null("Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 9/FLAMETHROWER")
		SHOTGUN_mesh = $Player_Weapon / Player_Weapon / Skeleton / BoneAttachment / Shotgun
		SKS_mesh = $Player_Weapon / Player_Weapon / Skeleton / BoneAttachment / SKS
		ROD_mesh = $"Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 24/Rod"
		BATON_mesh = $"Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 24/Cylinder003"
		PISTOL_mesh = $"Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 4/Pistol"
		NAILER_mesh = $"Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 4/Nailer"
		DART_mesh = $"Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 4/Dartgun"
		ZIPPY_mesh = $"Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 4/Zippy"
		SHOCK_mesh = $"Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 4/Shockwave"
		LIGHT_mesh = $Player_Weapon / LIGHT
		radiation_mesh = $Radiation_Area / MeshInstance
		radiation_cylinder = $"Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 9/RADGUN/cylinder"
		player_muzzle_flash = $Player_Weapon / Muzzleflash
		use_ray = $Use_Raycast
		AR_mesh.set_layer_mask_bit(2, 1)
		left_arm_mesh.set_layer_mask_bit(0, 0)
		left_arm_mesh.set_layer_mask_bit(2, 1)
		right_arm_mesh.set_layer_mask_bit(0, 0)
		right_arm_mesh.set_layer_mask_bit(2, 1)
		IM2 = $ImmediateGeometry2
		
		
		
		
		
		
		










	
		weapon1 = glob.menu.weapon_1
		weapon2 = glob.menu.weapon_2
		ammo[weapon1] += MAX_MAG_AMMO[weapon1] * glob.implants.torso_implant.ammo_bonus
		ammo[weapon2] += MAX_MAG_AMMO[weapon2] * glob.implants.torso_implant.ammo_bonus
		current_weapon = weapon1
		if orb:
			current_weapon = null
			weapon1 = null
			weapon2 = null
		
		if glob.implants.arm_implant.regen_ammo:
			regentimer1 = Timer.new()
			add_child(regentimer1)
			regentimer1.one_shot = true
			regentimer1.connect("timeout", self, "regen_timeout1")
			regentimer2 = Timer.new()
			add_child(regentimer2)
			regentimer2.one_shot = true
			regentimer2.connect("timeout", self, "regen_timeout2")
		
	initpos = translation
	initrot = rotation
	raycast_init_rot = raycast.rotation
	if player:
		raycast.set_collision_mask_bit(1, false)
		UI = glob.player.get_node("UI")
		set_UI_ammo()
	else :
		raycast.set_collision_mask_bit(2, false)
		laser_ray = get_node_or_null("Laser_Ray")
		if muzzle_light != null:
			muzzle_light.queue_free()
	audio = [get_node_or_null("Pistol_Sound"), get_node_or_null("SMG_Sound"), get_node_or_null("Dart_Sound"), get_node_or_null("Dart_Sound"), 
	get_node_or_null("Shotgun_Sound"), get_node_or_null("RL_Sound"), get_node_or_null("Sniper_Sound"), 
		get_node_or_null("AR_Sound"), get_node_or_null("S_SMG_Sound"), get_node_or_null("Nambu_Sound"), get_node_or_null("RL_Sound"), 
	[get_node_or_null("MG3_Sound"), get_node_or_null("MG3_Sound2")], get_node_or_null("Shotgun_Sound"), get_node_or_null("Pistol_Sound"), get_node_or_null("Shotgun_Sound"), get_node_or_null("Nambu_Sound"), get_node_or_null("Rad_Sound"), null, get_node_or_null("Nambu_Sound"), get_node_or_null("AN94_Sound"), get_node_or_null("VAG72_Sound"), get_node_or_null("Steyr_Sound"), get_node_or_null("FT_Sound"), get_node_or_null("FT_Sound"), get_node_or_null("FT_Sound"), get_node_or_null("Pistol_Sound"), get_node_or_null("Nailer_Sound"), get_node_or_null("Shotgun_Sound"), get_node_or_null("Light_Sound"), ]

func alert_body_entered(b):
	nearby.append(b)
func alert_body_exited(b):
	nearby.remove(nearby.find(b))

func hold(item):
	if get_tree().network_peer != null:
		item.holdId = get_tree().get_network_unique_id()
	else:
		var item_parent = item.get_parent()
		if "soul" in item:
			item.soul.remove_child(item)
			add_child(item)
		else :
			item.get_parent().remove_child(item)
			add_child(item)
	
	use_ray.add_exception(item)
	item.global_transform.origin = hold_pos.global_transform.origin
	
	held_object = item
	held_object_world = held_object.get_collision_layer_bit(0)
	held_object.set_collision_layer_bit(0, 0)
	held_object.set_collision_mask_bit(0, 0)
	held_object.set_collision_layer_bit(6, 0)
	
	held_object.rpc("_set_collision_layer",6,0)
	held_object.rpc("_set_collision_layer",0,0)
	held_object.rpc("_set_collision_mask",0,0)
		
	holding = true


func _input(event):
	if glob.implants.arm_implant.regen_ammo:
		return 
	if event is InputEventMouseMotion and player and current_weapon != null:
		if Input.is_action_pressed("reload"):
			rotate_x(deg2rad(event.relative.y * glob.mouse_sensitivity))
			
			var camera_rot = rotation_degrees
			camera_rot.x = clamp(camera_rot.x, 0, 75)
			rotation_degrees = camera_rot
			
			
			if camera_rot.x > 45 and magazine_ammo[current_weapon] < MAX_MAG_AMMO[current_weapon]:
				
				if current_weapon == W_NAMBU and ammo[current_weapon] > 0:
					spawn_shell(SHELLS[current_weapon], clamp(MAX_MAG_AMMO[current_weapon] - magazine_ammo[current_weapon], 1, 5), 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
				reload()

func regen_timeout1():
	if weapon1 != null:
		magazine_ammo[weapon1] += 1
		set_UI_ammo()
func regen_timeout2():
	if weapon2 != null:
		magazine_ammo[weapon2] += 1
		set_UI_ammo()
func _physics_process(delta):
	
	if disabled:
		return 
	recoil = lerp(recoil, 0, 4 * delta)
	if not player:
		return 
	if glob.implants.arm_implant.regen_ammo and player:
		if weapon1 != null:
			if magazine_ammo[weapon1] < MAX_MAG_AMMO[weapon1] and regentimer1.is_stopped():
				regentimer1.start(5 / MAX_MAG_AMMO[weapon1])
		if weapon2 != null:
			if magazine_ammo[weapon2] < MAX_MAG_AMMO[weapon2] and regentimer2.is_stopped():
				regentimer2.start(5 / MAX_MAG_AMMO[weapon2])
	if not reload_timer.is_stopped() and player and not Input.is_action_pressed("reload"):
		rotation.x = lerp(rotation.x, initrot.x + 0.5, 5 * delta)
	elif player:
		rotation.x = lerp(rotation.x, initrot.x, 4 * delta)
	
	if kickflag:
		kicktimer += delta * 35
func draw_line(begin, end):
	begin = global_transform.xform_inv(begin)
	end = global_transform.xform_inv(end)
	IM.add_vertex(begin)
	IM.add_vertex(end)
func draw_line2(begin, end):
	begin = global_transform.xform_inv(begin)
	end = global_transform.xform_inv(end)
	IM2.add_vertex(begin)
	IM2.add_vertex(end)

func normalize(value, mn, mx):
	var norm
	norm = (value - mn) / (mx - mn)
	return norm

func _process(delta)->void :
	if disabled:
		return 
	
		
			
				
				
				
	t += 1
	if not player:
		raycast_init_rot.x = rand_range( - enemy_accuracy, enemy_accuracy)
		raycast_init_rot.y = rand_range( - enemy_accuracy, enemy_accuracy)
		if (reload_timer.is_stopped() and magazine_ammo[current_weapon] == 0 and ammo[current_weapon] > 0):
			reload()
		return 
		

	
	
	
	if player:
		if Global.implants.arm_implant.ricochet:
			if raycast.is_colliding():
				IM2.clear()
				IM2.begin(line_mesh.PRIMITIVE_LINES)
				
				
				
				
				
				
				
				var begin = raycast.get_collision_point()
				var end = begin + (begin - raycast.global_transform.origin).bounce(raycast.get_collision_normal())
				
				draw_line2(begin, end)
				IM2.end()
			else :
				IM2.clear()
		if fishing_hook != null:
			IM.clear()
			IM.begin(line_mesh.PRIMITIVE_LINES)
			var rodpos = $"Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 24/Rod/RodPos"
			var dist = rodpos.global_transform.origin.distance_to(fishing_hook.global_transform.origin)
			var n = - (rodpos.global_transform.origin - fishing_hook.global_transform.origin).normalized()
			var res = 20
			var ratio = dist / res
			var gravity = 22
			
			var begin = rodpos.global_transform.origin
			var end = fishing_hook.global_transform.origin
			draw_line(begin, end)
			IM.end()
		else :
			IM.clear()
		if (current_weapon != W_ROD or Global.player.water) and fishing_hook != null:
			if is_instance_valid(fishing_hook):
				fishing_hook.queue_free()
			fishing_hook = null
		if current_weapon == W_BLACKJACK or current_weapon == W_ROD:
			melee = true
		else :
			melee = false
		if grapple_flag:
			if grapple_point != null:
				glob.player.grapple(grapple_point)
			if grapple_target != null:
				grapple_target.grapple(grapple_point)
		
		radiation_cylinder.rotation.z -= cylinder_velocity
		RAD_light.light_energy = cylinder_velocity * 10
		if current_weapon != W_RADIATOR:
			RAD_light.hide()
		else :
			RAD_light.show()
		cylinder_velocity = lerp(cylinder_velocity, 0, 0.01)
		
		radiation_mesh.scale.z = lerp(radiation_mesh.scale.z, 0, 0.5)
		radiation_mesh.scale.x = lerp(radiation_mesh.scale.x, 0, 0.5)
		if current_weapon == W_LIGHT:
			LIGHT_mesh.show()
		else :
			LIGHT_mesh.hide()
		if current_weapon == W_AR:
			FT_mesh.hide()
			STEYR_mesh.hide()
			AR_mesh.show()
			MKR_mesh.hide()
			RAD_mesh.hide()
			AN94_mesh.hide()
		elif current_weapon == W_MKR:
			FT_mesh.hide()
			STEYR_mesh.hide()
			AR_mesh.hide()
			MKR_mesh.show()
			RAD_mesh.hide()
			AN94_mesh.hide()
		elif current_weapon == W_RADIATOR:
			FT_mesh.hide()
			STEYR_mesh.hide()
			AR_mesh.hide()
			MKR_mesh.hide()
			RAD_mesh.show()
			AN94_mesh.hide()
		elif current_weapon == W_AN94:
			FT_mesh.hide()
			STEYR_mesh.hide()
			AR_mesh.hide()
			MKR_mesh.hide()
			RAD_mesh.hide()
			AN94_mesh.show()
		elif current_weapon == W_STEYR:
			FT_mesh.hide()
			STEYR_mesh.show()
			AR_mesh.hide()
			MKR_mesh.hide()
			RAD_mesh.hide()
			AN94_mesh.hide()
		elif current_weapon == W_FLAMETHROWER:
			FT_mesh.show()
			STEYR_mesh.hide()
			AR_mesh.hide()
			MKR_mesh.hide()
			RAD_mesh.hide()
			AN94_mesh.hide()
		if current_weapon == W_PISTOL:
			SHOCK_mesh.hide()
			NAILER_mesh.hide()
			DNA_mesh.hide()
			PISTOL_mesh.show()
			VAG72_mesh.hide()
			DART_mesh.hide()
			ZIPPY_mesh.hide()
		elif current_weapon == W_TRANQ:
			SHOCK_mesh.hide()
			NAILER_mesh.hide()
			DNA_mesh.hide()
			VAG72_mesh.hide()
			DART_mesh.show()
			PISTOL_mesh.hide()
			ZIPPY_mesh.hide()
		elif current_weapon == W_ZIPPY:
			SHOCK_mesh.hide()
			NAILER_mesh.hide()
			DNA_mesh.hide()
			VAG72_mesh.hide()
			DART_mesh.hide()
			PISTOL_mesh.hide()
			ZIPPY_mesh.show()
		elif current_weapon == W_VAG72:
			SHOCK_mesh.hide()
			NAILER_mesh.hide()
			DNA_mesh.hide()
			VAG72_mesh.show()
			DART_mesh.hide()
			PISTOL_mesh.hide()
			ZIPPY_mesh.hide()
		elif current_weapon == W_CANCER:
			SHOCK_mesh.hide()
			NAILER_mesh.hide()
			DNA_mesh.show()
			VAG72_mesh.hide()
			DART_mesh.hide()
			PISTOL_mesh.hide()
			ZIPPY_mesh.hide()
		elif current_weapon == W_NAILER:
			SHOCK_mesh.hide()
			NAILER_mesh.show()
			DNA_mesh.hide()
			VAG72_mesh.hide()
			DART_mesh.hide()
			PISTOL_mesh.hide()
			ZIPPY_mesh.hide()
		elif current_weapon == W_SHOCK:
			SHOCK_mesh.show()
			NAILER_mesh.hide()
			DNA_mesh.hide()
			VAG72_mesh.hide()
			DART_mesh.hide()
			PISTOL_mesh.hide()
			ZIPPY_mesh.hide()
		if current_weapon == W_SHOTGUN:
			SHOTGUN_mesh.show()
			$"Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 2/Shotgun_Pump".show()
			SKS_mesh.hide()
		elif current_weapon == W_SKS:
			SHOTGUN_mesh.hide()
			SKS_mesh.show()
			$"Player_Weapon/Player_Weapon/Skeleton/BoneAttachment 2/Shotgun_Pump".hide()
		
		
		if current_weapon == W_BLACKJACK:
			BATON_mesh.show()
			ROD_mesh.hide()
		elif current_weapon == W_ROD:
			BATON_mesh.hide()
			ROD_mesh.show()
		if current_weapon == W_FLAMETHROWER and not Input.is_action_pressed("mouse_1"):
				audio[current_weapon].stop()
		leaning = Input.is_action_pressed("Lean_Left") or Input.is_action_pressed("Lean_Right")
		player_muzzle_flash.hide()
		if Input.is_action_just_pressed("drop") and current_weapon != null:
			randomize()
			var randName = int(rand_range(0,1000000))
			var new_weapon_drop = weapon_drop.instance()
			new_weapon_drop.set_name(new_weapon_drop.name + "#" + str(randName))
			get_tree().get_nodes_in_group("Sync")[0].add_child(new_weapon_drop)
			new_weapon_drop.global_transform.origin = global_transform.origin
			new_weapon_drop.gun.MESH[new_weapon_drop.gun.current_weapon].hide()
			new_weapon_drop.gun.current_weapon = current_weapon
			new_weapon_drop.gun.ammo = magazine_ammo[current_weapon]
			new_weapon_drop.rotation.y = rand_range( - PI, PI)
			new_weapon_drop.velocity -= (20 + glob.implants.arm_implant.throw_bonus) * (global_transform.origin - hold_pos.global_transform.origin).normalized()
			new_weapon_drop.velocity += glob.player.player_velocity
			new_weapon_drop.gun.MESH[current_weapon].show()
			rpc("_create_drop_weapon",global_transform.origin,hold_pos.global_transform.origin,glob.implants.arm_implant.throw_bonus,current_weapon,magazine_ammo[current_weapon],glob.player.player_velocity,randName)
			if weapon1 == current_weapon:
				weapon1 = null
			if weapon2 == current_weapon:
				weapon2 = null
			current_weapon = null
			zoom_flag = false
			player_weapon.hide()
			glob.player.set_move_speed()
		if holding:
			var pos = hold_pos.global_transform.origin
			if use_ray.is_colliding():
				if global_transform.origin.distance_to(use_ray.get_collision_point()) < global_transform.origin.distance_to(hold_pos.global_transform.origin):
					pos = use_ray.get_collision_point()
			held_object.global_transform.origin = pos
			held_object.velocity = Vector3.ZERO
			var col_is_usable
			if use_ray.is_colliding():
				var collider = use_ray.get_collider()
				if collider != null:
					col_is_usable = use_ray.get_collider().get_collision_layer_bit(8)
			if Input.is_action_just_pressed("Use") and not col_is_usable:
				holding = false
				
				if get_tree().network_peer != null:
					held_object.holdId = 0
					held_object.held = false
					held_object.rset("held",false)
					held_object.rset("holdId",0)
					
					held_object.set_collision_layer_bit(6, 1)
					held_object.set_collision_layer_bit(0, 1)
					held_object.set_collision_mask_bit(0, 1)
					
					held_object.rpc("_set_collision_layer",6,1)
					held_object.rpc("_set_collision_layer",0,1)
					held_object.rpc("_set_collision_mask",0,1)
				else:
					if "soul" in held_object:
						held_object.get_parent().remove_child(held_object)
						held_object.soul.add_child(held_object)
					else :
						held_object.get_parent().remove_child(held_object)
						glob.player.get_parent().add_child(held_object)
						held_object.set_collision_layer_bit(6, 1)
					held_object.global_transform.origin = pos
					if held_object_world:
						held_object.set_collision_layer_bit(0, 1)
					
					held_object.set_collision_mask_bit(0, 1)
					yield (get_tree(), "idle_frame")
					if is_instance_valid(held_object):
						use_ray.remove_exception(held_object)
						if "held" in held_object:
							held_object.held = false
			
			if Input.is_action_just_pressed("kick") and not col_is_usable:
				holding = false
				
				if get_tree().network_peer != null:
					held_object.holdId = 0
					held_object.held = false
					held_object.rset("held",false)
					held_object.rset("holdId",0)
					
					var calculatedVelocity
					if "mass" in held_object:
						calculatedVelocity = (20 + glob.implants.arm_implant.throw_bonus - held_object.mass) * (global_transform.origin - hold_pos.global_transform.origin).normalized()
					else :
						calculatedVelocity = (20 + glob.implants.arm_implant.throw_bonus) * (global_transform.origin - hold_pos.global_transform.origin).normalized()
					held_object.velocity += glob.player.player_velocity
					held_object.rset("velocity",held_object.velocity + glob.player.player_velocity - calculatedVelocity)
					
					held_object.set_collision_layer_bit(6, 1)
					held_object.set_collision_layer_bit(0, 1)
					held_object.set_collision_mask_bit(0, 1)
					
					held_object.rpc("_set_collision_layer",6,1)
					held_object.rpc("_set_collision_layer",0,1)
					held_object.rpc("_set_collision_mask",0,1)
				else:
					if "alerter" in held_object:
						held_object.alerter = true
					if "soul" in held_object:
						held_object.get_parent().remove_child(held_object)
						held_object.soul.add_child(held_object)
					else :
						held_object.get_parent().remove_child(held_object)
						glob.player.get_parent().add_child(held_object)
					held_object.global_transform.origin = pos
					if "mass" in held_object:
						held_object.velocity -= (20 + glob.implants.arm_implant.throw_bonus - held_object.mass) * (global_transform.origin - hold_pos.global_transform.origin).normalized()
					else :
						held_object.velocity -= (20 + glob.implants.arm_implant.throw_bonus) * (global_transform.origin - hold_pos.global_transform.origin).normalized()
					held_object.velocity += glob.player.player_velocity
					if held_object_world:
						held_object.set_collision_layer_bit(0, 1)
					held_object.set_collision_mask_bit(0, 1)
					if "alerter" in held_object:
						held_object.set_collision_layer_bit(6, 1)
					yield (get_tree(), "idle_frame")
					if is_instance_valid(held_object):
						use_ray.remove_exception(held_object)
						if "held" in held_object:
							held_object.held = false

		if not is_zero_approx(player_weapon.rotation.z):
			player_weapon.rotation.z = lerp(player_weapon.rotation.z, 0, 0.8)
		if not is_zero_approx(player_weapon.rotation.x):
			player_weapon.rotation.x = lerp(player_weapon.rotation.x, 0, 0.8)
		
		if leaning:
			player_weapon.transform.origin.y = lerp(player_weapon.transform.origin.y, - 0.4, 5 * delta)
			leaning_modifier = 0.1
			glob.player.reticle.shoot()
		else :
			player_weapon.transform.origin.y = lerp(player_weapon.transform.origin.y, - 0.078, 5 * delta)
			leaning_modifier = 0
		
		
		
		
		
		
		if use_ray.is_colliding():
			var collider = use_ray.get_collider()
			if collider != null:
				if collider.get_collision_layer_bit(8):
					glob.player.grab_hand.show()
				else :
					glob.player.grab_hand.hide()
		else :
			glob.player.grab_hand.hide()
		
		if current_weapon == W_AR:
			
			AR_dot.show()
			
			
			
		else :
			AR_dot.hide()
		if current_weapon == W_PISTOL or current_weapon == W_SILENCED_SMG or current_weapon == W_NAILER:
			if raycast.is_colliding():
				glob.player.UI.distance(global_transform.origin.distance_to(raycast.get_collision_point()))
				if not leaning:
					raycast.rotation = raycast_init_rot
				else :
					raycast.rotation = Vector3(sin(t * 0.05) * 0.05, cos(t * 0.0732) * 0.051, raycast_init_rot.z)
				laser_dot.global_transform.origin = raycast.get_collision_point() + raycast.get_collision_normal() * 1e-06
				laser_dot.show()
				
				glob.player.reticle.reticle_color = Color(0, 1, 0, 0.5)
		else :
			glob.player.reticle.show()
			glob.player.reticle.reticle_color = Color(1, 0, 0, 1)
			laser_dot.hide()
		
		UI.reload_pos.y = rotation_degrees.x / 75 * UI.get_viewport().size.y
		
		if current_weapon != null and not glob.player.psychosis:
			if zoom_flag and (current_weapon == W_SNIPER or current_weapon == W_MAUSER):
				glob.player.player_view.fov = lerp(glob.player.player_view.fov, 10, 5 * delta)
				
				glob.player.set_scope(true)
				player_weapon.hide()
			elif zoom_flag and current_weapon == W_AR:
				glob.player.set_scope(true)
				
				player_weapon.hide()
				player_weapon.transform.origin.x = lerp(player_weapon.transform.origin.x, 0.0, 5 * delta)
				
				
				glob.player.player_view.fov = lerp(glob.player.player_view.fov, 15, 5 * delta)
			elif zoom_flag:
				glob.player.set_scope(false)
				
				player_weapon.show()
				player_weapon.transform.origin.x = lerp(player_weapon.transform.origin.x, 0.02, 5 * delta)
				glob.player.player_view.fov = lerp(glob.player.player_view.fov, glob.FOV * 0.6 * glob.implants.head_implant.zoom_bonus, 5 * delta)
			else :
				player_weapon.show()
				player_weapon.transform.origin.x = lerp(player_weapon.transform.origin.x, - 0.135, 5 * delta)
				glob.player.player_view.fov = lerp(glob.player.player_view.fov, glob.FOV, 5 * delta)
				
				glob.player.set_scope(false)
		else :
			if not glob.player.psychosis:
				glob.player.player_view.fov = lerp(glob.player.player_view.fov, glob.FOV, 5 * delta)
			glob.player.set_scope(false)
			
			
				
	
	
	
	

	if player:
		
		if muzzle_light.light_energy < 0.1:
			muzzle_light.hide()
		else :
			muzzle_light.show()
			muzzle_light.light_energy = lerp(muzzle_light.light_energy, 0, 0.7)
		if orb:
			collision_ray.cast_to.z = 2
		if collision_ray.is_colliding():
			weapon_mesh_z = 0.312 - (collision_ray.cast_to.z - collision_ray.global_transform.origin.distance_to(collision_ray.get_collision_point()))
		else :
			weapon_mesh_z = 0.312
		player_weapon.transform.origin.z = lerp(player_weapon.transform.origin.z, weapon_mesh_z, clamp(delta * 30, 0, 1))
		if orb:
			$orbarms.transform.origin.z = player_weapon.transform.origin.z
		if rotation_degrees.x > 1 and current_weapon != null:
			reload_sound.play()
			reload_sound.seek(rotation_degrees.x / 45 * reload_sound.stream.get_length())
		else :
			reload_sound.stop()
		if (Input.is_action_pressed("reload") or rotation_degrees.x > 5) and current_weapon != null:
			UI.reload_color = Color(0, 1, 0, 1)
			zoom_flag = false
		else :
			UI.reload_color = Color(0, 0, 0, 0)
		if Input.is_action_just_pressed("kick") and not $Player_Leg / AnimationPlayer.is_playing() and not leaning and not glob.implants.torso_implant.thrust and not glob.implants.torso_implant.jetpack and not holding and not orb:
			$Player_Leg / AnimationPlayer.play("Kick")
			$Kicksound2.play()
			rpc("_play_sound","Kicksound2")
			kicktimer = 0
			kickflag = true
		elif glob.implants.torso_implant.thrust and Input.is_action_just_pressed("kick") and kicktimer >= 40:
			glob.player.friction_disabled = true
			kicktimer = 0
			kickflag = true
		elif glob.implants.torso_implant.jetpack and Input.is_action_pressed("kick"):
			glob.player.player_velocity.y += delta * 30
			
			$JetPack.seek(abs(sin(t)) * 0.5)
			$JetPack.play()
			glob.player.wish_jump = true
		
		if kicktimer < 10 and glob.implants.torso_implant.thrust and kickflag:
			glob.player.thrust()
		elif glob.implants.torso_implant.thrust and kicktimer >= 40:
			kickflag = false
			glob.player.friction_disabled = false
			
		if (kicktimer >= 10 or (kicktimer >= 6 and glob.implants.leg_implant.kick_improvement)) and kickflag and not glob.implants.torso_implant.thrust:
			
			for i in range(12):
				raycast.rotation = raycast_init_rot + Vector3(0, rand_range( - 0.1, 0.1), 0)
				raycast.force_raycast_update()
				if raycast.is_colliding() and kickflag:
					
					raycast.force_raycast_update()
					var collider = raycast.get_collider()
					var col_p = raycast.get_collision_point()
					var col_n = (global_transform.origin + Vector3.DOWN - ($Front_Pos_Helper.global_transform.origin + Vector3.UP * 3)).normalized()
					if global_transform.origin.distance_to(col_p) < 3 and is_instance_valid(collider):
						kickflag = false
						$Kicksound.play()
						rpc("_play_sound","Kicksound")
						var kick_damage = 60
						var kick_velocity = 20
						var kick_multiplier = 1
						if glob.implants.leg_implant.kick_improvement:
							kick_damage = 100
							kick_velocity = 30
							kick_multiplier = 2
						glob.player.player_velocity += 5 * col_n * kick_multiplier
						glob.player.player_view.fov *= 1.02
						if collider.has_method("destroy"):
							
							collider.destroy(col_n, col_p)
						elif collider.has_method("damage"):
							
							collider.damage(kick_damage, col_n, col_p, global_transform.origin)
						if collider.has_method("add_velocity"):
							collider.add_velocity(40, col_n)
			kickflag = false
		if Input.is_action_just_pressed("Tertiary_Weapon") and not item_consumed:
			if glob.implants.arm_implant.grapple:
				if raycast.is_colliding() and not grapple_flag:
					var collider = raycast.get_collider()
					var point = raycast.get_collision_point()
					
					if global_transform.origin.distance_to(point) < 20:
						grapple_point = Position3D.new()
						
						if collider.has_method("grapple"):
							grapple_target = collider
							collider.soul.body.add_child(grapple_point)
						else :
							grapple_target = null
							collider.add_child(grapple_point)
						grapple_point.global_transform.origin = point
						grapple_flag = true
				elif raycast.is_colliding():
					grapple_flag = false
					
				if not grapple_flag:
					for o in glob.player.grapple_orbs:
						o.queue_free()
					glob.player.grapple_orbs = []
				if not raycast.is_colliding():
					grapple_flag = false
					for o in glob.player.grapple_orbs:
						o.queue_free()
					glob.player.grapple_orbs = []
			if glob.implants.arm_implant.healing != 0:
				item_consumed = true
				glob.player.add_health(glob.implants.arm_implant.healing)
			if glob.implants.arm_implant.he_grenade and grenade_ammo > 0:
				grenade_ammo -= 1
				var missile_new = GRENADE.instance()
				if player:
					get_parent().get_parent().get_parent().add_child(missile_new)
				else :
					get_parent().get_parent().get_parent().get_parent().add_child(missile_new)
				if player:
					missile_new.set_collision_mask_bit(1, 0)
				else :
					missile_new.set_collision_mask_bit(1, 1)
					missile_new.set_collision_mask_bit(2, 0)
				missile_new.global_transform.origin = global_transform.origin
				missile_new.set_velocity(20, (global_transform.origin - $Front_Pos_Helper.global_transform.origin).normalized(), global_transform.origin)
				missile_new.velocity += glob.player.player_velocity
			if glob.implants.arm_implant.flechette_grenade and grenade_ammo > 0:
				grenade_ammo -= 1
				var missile_new = FLECHETTE_GRENADE.instance()
				if player:
					get_parent().get_parent().get_parent().add_child(missile_new)
				else :
					get_parent().get_parent().get_parent().get_parent().add_child(missile_new)
				if player:
					missile_new.set_collision_mask_bit(1, 0)
				else :
					missile_new.set_collision_mask_bit(1, 1)
					missile_new.set_collision_mask_bit(2, 0)
				missile_new.global_transform.origin = global_transform.origin
				missile_new.set_velocity(20, (global_transform.origin - $Front_Pos_Helper.global_transform.origin).normalized(), global_transform.origin)
				missile_new.velocity += glob.player.player_velocity
			if glob.implants.arm_implant.sleep_grenade and grenade_ammo > 0:
				grenade_ammo -= 1
				var missile_new = SLEEP_GRENADE.instance()
				if player:
					get_parent().get_parent().get_parent().add_child(missile_new)
				else :
					get_parent().get_parent().get_parent().get_parent().add_child(missile_new)
				if player:
					missile_new.set_collision_mask_bit(1, 0)
				else :
					missile_new.set_collision_mask_bit(1, 1)
					missile_new.set_collision_mask_bit(2, 0)
				missile_new.global_transform.origin = global_transform.origin
				missile_new.set_velocity(20, (global_transform.origin - $Front_Pos_Helper.global_transform.origin).normalized(), global_transform.origin)
				missile_new.velocity += glob.player.player_velocity
			if glob.implants.arm_implant.radio:
				if radio != null:
					radio.queue_free()
				radio = RADIO.instance()
				Global.player.get_parent().add_child(radio)
				radio.global_transform.origin = global_transform.origin
				radio.velocity -= (global_transform.origin - $Front_Pos_Helper.global_transform.origin).normalized() * 5
				radio.velocity -= glob.player.player_velocity
				
		if current_weapon != null:
			if Input.is_action_just_pressed("mouse_1") and magazine_ammo[current_weapon] <= 0:
				if not $No_Ammo.playing:
					$No_Ammo.play()
		if Input.is_action_just_pressed("mouse_1") and reload_timer.is_stopped() and current_weapon == null and glob.implants.head_implant.skullgun and not leaning and not orb:
			skullgun()
		if orb:
			if orb_anim.is_playing() and orb_anim.current_animation_position > 0.4 and orb_anim.current_animation_position < 0.5:
				var col_n = (global_transform.origin + Vector3.DOWN - ($Front_Pos_Helper.global_transform.origin + Vector3.UP * 3)).normalized()
				for b in $"orbarms/L_Arm/Bone 2/Bone001 2/Bone002 2/Bone003 2/Bone004 2/Sphere010/L_Orb".get_overlapping_bodies():
					if not $Kicksound.playing:
						$Kicksound.play()
						rpc("_play_sound","Kicksound")
					if b.get_class() == "StaticBody" and not Global.player.is_on_floor():
						glob.player.player_velocity += col_n * 4
					if b.has_method("damage"):
						b.damage(100, (global_transform.origin - b.global_transform.origin).normalized(), b.global_transform.origin, Vector3.ZERO)
			if $orbarms / AnimationPlayer2.is_playing() and $orbarms / AnimationPlayer2.current_animation_position > 0.4 and $orbarms / AnimationPlayer2.current_animation_position < 0.5:
				var col_n = (global_transform.origin + Vector3.DOWN - ($Front_Pos_Helper.global_transform.origin + Vector3.UP * 3)).normalized()
				print($orbarms / AnimationPlayer2.current_animation_position)
				for b in $orbarms / R_Arm / Bone / Bone001 / Bone002 / Bone003 / Bone004 / Sphere004 / R_Orb.get_overlapping_bodies():
					if not $Kicksound.playing:
						$Kicksound.play()
						rpc("_play_sound","Kicksound")
					if b.get_class() == "StaticBody" and not Global.player.is_on_floor():
						glob.player.player_velocity += col_n * 4
					if b.has_method("damage"):
						
						b.damage(100, (global_transform.origin - b.global_transform.origin).normalized(), b.global_transform.origin, Vector3.ZERO)
		if Input.is_action_just_pressed("mouse_1") and orb:
			
			if orb_left:
				if orb_anim.is_playing():
					return 
				orb_anim.play("Attack", - 1)
				orb_left = not orb_left
				
			else :
				if $orbarms / AnimationPlayer2.is_playing():
					return 
				$orbarms / AnimationPlayer2.play("AttackR", - 1)
				orb_left = not orb_left
				
		if Input.is_action_pressed("mouse_1") and reload_timer.is_stopped() and current_weapon != null:
			if magazine_ammo[current_weapon] > 0:
				rotation.x = initrot.x
				shoot()
				

			
		
		if Input.is_action_just_pressed("zoom"):
			zoom()
		
		if Input.is_action_just_pressed("weapon1") and reload_timer.is_stopped():
			if current_weapon == weapon1:
				return 
			anim.stop()
			anim.play("Nogun", - 1, 100)
			
			current_weapon = weapon1
			held_weapon = 1
			
			if current_weapon == null:
				player_weapon.hide()
			else :
				player_weapon.show()
			set_UI_ammo()
		
		if Input.is_action_just_pressed("switch_weapon") and reload_timer.is_stopped():
			anim.stop()
			anim.play("Nogun", - 1, 100)
			if current_weapon == weapon1:
				current_weapon = weapon2
			elif current_weapon == weapon2:
				current_weapon = weapon1
			set_UI_ammo()
			if current_weapon == null:
				player_weapon.hide()
			else :
				player_weapon.show()
			Global.player.reticle.update()

		
		if Input.is_action_just_pressed("weapon2") and reload_timer.is_stopped():

			if current_weapon == weapon2:
				return 
			anim.stop()
			anim.play("Nogun", - 1, 100)
			
			held_weapon = 2
			current_weapon = weapon2
			
			set_UI_ammo()
			if current_weapon == null:
				player_weapon.hide()
			else :
				player_weapon.show()
		
		
		if current_weapon == W_FLASHLIGHT and flash_light_switch:
			flashlight.show()
		else :
			flashlight.hide()
		if Input.is_action_just_pressed("Use") and $Use_Raycast.is_colliding():
			var collider = $Use_Raycast.get_collider()
			if collider.has_method("use"):
				collider.use()
			if collider.has_method("player_use"):
				collider.player_use()
		if current_weapon == null:
			return 
		if timer.is_stopped() and not anim.is_playing():
			if melee and Input.is_action_pressed("mouse_1"):

				fish_strength += 1
				fish_strength = clamp(fish_strength, 15, 40)
				pass
			else :
				anim.play(IDLE_ANIM[current_weapon], - 1, 1.0)
		if melee and Input.is_action_just_released("mouse_1"):
			
			if timer.is_stopped():
				anim.play("Baton_Fire2", - 1, 1.5)
				$Kicksound2.play()
				rpc("_play_sound","Kicksound2")
				blackjacktimer.start(anim.current_animation_length - 0.2)
			else :
				timer.stop()
				fish_strength = 0
				anim.play("Baton_Idle")
		if not timer.is_stopped() and not anim.is_playing() and current_weapon == W_SHOTGUN:
			anim.play("Shotgun_Reload", - 1, 0.6)
			$Shotgun_Pump.play()
		if not timer.is_stopped() and not anim.is_playing() and current_weapon == W_SNIPER:
			anim.play("Sniper_Bolt", - 1, 1.0)
			yield (get_tree().create_timer(0.4), "timeout")
			$Shotgun_Pump.pitch_scale = 0.4
			$Shotgun_Pump.play()
			


		if Input.is_action_just_pressed("weapon5") and reload_timer.is_stopped() and glob.debug:
			if current_weapon == W_SILENCED_SMG:
				return 
			anim.stop()
			weapon2 = current_weapon
			current_weapon = W_LIGHT
			weapon1 = current_weapon
			set_UI_ammo()
		if Input.is_action_just_pressed("weapon6") and reload_timer.is_stopped() and glob.debug:
			if current_weapon == W_AR:
				return 
			anim.stop()
			weapon2 = current_weapon
			current_weapon = W_NAILER
			weapon1 = current_weapon
			set_UI_ammo()
		
		
				
				
	

	
		
	

		
func reload()->void :
	
	ammo[current_weapon] -= MAX_MAG_AMMO[current_weapon] - magazine_ammo[current_weapon]
	magazine_ammo[current_weapon] += MAX_MAG_AMMO[current_weapon] - magazine_ammo[current_weapon]
	if ammo[current_weapon] <= 0:
		magazine_ammo[current_weapon] += ammo[current_weapon]
		ammo[current_weapon] = 0
	set_UI_ammo()

func cancer()->void :
	if timer.is_stopped():
		timer.start(0.2)
		audio[0].play()
		if player:
			magazine_ammo[current_weapon] -= 1
		raycast.rotation = raycast_init_rot
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			if collider.has_method("cancer"):
				collider.cancer()
		if player:
			spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
			muzzle_light.light_energy = 1
			player_muzzle_flash.show()
			player_muzzle_flash.rotation.x = rand_range( - PI, PI)
			player_muzzle_flash.scale = Vector3(rand_range(0.2, 0.5), rand_range(0.2, 0.5), rand_range(0.2, 0.5))
			get_parent().rotation.x -= rand_range(0, 0.02)
			glob.player.reticle.shoot()
			
			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])

func smg()->void :
	if timer.is_stopped():
		raycast.force_raycast_update()
		var rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
		if not player:
			rayrot += Vector3(rand_range( - enemy_accuracy, enemy_accuracy), rand_range( - enemy_accuracy, enemy_accuracy), 0)
		raycast.rotation = rayrot
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if player and glob.implants.arm_implant.ricochet:
				ricochet(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			do_damage(collider)
		timer.start(0.07)
		recoil += accuracy[current_weapon]
		

		if player:
			muzzle_light.light_energy = 1
			player_muzzle_flash.show()
			player_muzzle_flash.rotation.x = rand_range( - PI, PI)
			player_muzzle_flash.scale = Vector3(rand_range(0.2, 0.5), rand_range(0.2, 0.5), rand_range(0.2, 0.5))
			get_parent().rotation.x -= rand_range(0, 0.02)
			glob.player.reticle.shoot()
			spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])
		else :
			if get_parent().get_parent().muzzleflash:
				get_parent().get_parent().muzzleflash.show()
		audio[current_weapon].play()
		audio[current_weapon].pitch_scale = float(magazine_ammo[current_weapon]) / MAX_MAG_AMMO[current_weapon] + 0.4 + rand_range( - 0.1, 0.1)
		magazine_ammo[current_weapon] -= 1

func steyr()->void :
	if timer.is_stopped():
		
		


		if not player:
			if get_parent().get_parent().muzzleflash:
				get_parent().get_parent().muzzleflash.show()
		audio[current_weapon].play()
		
		
		timer.start(0.2)
		raycast.force_raycast_update()
		var rayrot:Vector3 = Vector3(rand_range( - (leaning_modifier), leaning_modifier), rand_range( - (leaning_modifier), leaning_modifier), raycast_init_rot.z)
		if not player:
			rayrot += Vector3(rand_range( - enemy_accuracy, enemy_accuracy), rand_range( - enemy_accuracy, enemy_accuracy), 0)
		raycast.rotation = rayrot
		raycast.force_raycast_update()
		if magazine_ammo[current_weapon] > 0:
			if player:
				muzzle_light.light_energy = 1
				player_muzzle_flash.show()
				player_muzzle_flash.rotation.x = rand_range( - PI, PI)
				player_muzzle_flash.scale = Vector3(rand_range(0.2, 0.5), rand_range(0.2, 0.5), rand_range(0.2, 0.5))
				magazine_ammo[current_weapon] -= 1
				get_parent().rotation.x -= rand_range(0, 0.005)
				glob.player.reticle.shoot()
				anim.stop()
				anim.play(FIRE_ANIM[current_weapon])
				set_UI_ammo()
				spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
			if raycast.is_colliding():
				var collider = raycast.get_collider()

				if not collider.has_method("destroy"):
					flechette(collider)
				var collision_p = raycast.get_collision_point()
				if collider.has_method("piercing_damage"):
					collider.piercing_damage(damage[current_weapon], Vector3.ZERO, collision_p, global_transform.origin)
				shoot_through(collider, collision_p)
				do_damage(collider)
				
		yield (get_tree(), "physics_frame")
		yield (get_tree(), "physics_frame")
		
		
		rayrot.x += 0.005
		raycast.rotation = rayrot
		raycast.rotation.y = 0.005
		raycast.force_raycast_update()
		if magazine_ammo[current_weapon] > 0:
			if player:
				muzzle_light.light_energy = 1
				player_muzzle_flash.show()
				player_muzzle_flash.rotation.x = rand_range( - PI, PI)
				player_muzzle_flash.scale = Vector3(rand_range(0.2, 0.5), rand_range(0.2, 0.5), rand_range(0.2, 0.5))
				spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
				magazine_ammo[current_weapon] -= 1
				get_parent().rotation.x -= rand_range(0, 0.005)
				glob.player.reticle.shoot()
				anim.stop()
				anim.play(FIRE_ANIM[current_weapon])
				set_UI_ammo()
			if raycast.is_colliding():
				var collider = raycast.get_collider()
				if not collider.has_method("destroy"):
					flechette(collider)
				var collision_p = raycast.get_collision_point()
				if collider.has_method("piercing_damage"):
					collider.piercing_damage(damage[current_weapon], Vector3.ZERO, collision_p, global_transform.origin)
				shoot_through(collider, collision_p)
				do_damage(collider)

		
		yield (get_tree(), "physics_frame")
		yield (get_tree(), "physics_frame")
		raycast.rotation = rayrot
		raycast.rotation.y = - 0.005
		raycast.force_raycast_update()
		if magazine_ammo[current_weapon] > 0:
			if player:
				muzzle_light.light_energy = 1
				player_muzzle_flash.show()
				player_muzzle_flash.rotation.x = rand_range( - PI, PI)
				player_muzzle_flash.scale = Vector3(rand_range(0.2, 0.5), rand_range(0.2, 0.5), rand_range(0.2, 0.5))
				magazine_ammo[current_weapon] -= 1
				get_parent().rotation.x -= rand_range(0, 0.005)
				glob.player.reticle.shoot()
				anim.stop()
				anim.play(FIRE_ANIM[current_weapon])
				set_UI_ammo()
				spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
			if raycast.is_colliding():
				var collider = raycast.get_collider()
				var collision_p = raycast.get_collision_point()
				shoot_through(collider, collision_p)
				if not collider.has_method("destroy"):
					flechette(collider)
				if collider.has_method("piercing_damage"):
					collider.piercing_damage(damage[current_weapon], Vector3.ZERO, collision_p, global_transform.origin)
				do_damage(collider)
		
		
		


		



func mkr()->void :
	if timer.is_stopped():
		raycast.force_raycast_update()
		var rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
		if not player:
			rayrot += Vector3(rand_range( - enemy_accuracy, enemy_accuracy), rand_range( - enemy_accuracy, enemy_accuracy), 0)
		raycast.rotation = rayrot
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			var colpoint = raycast.get_collision_point()
			if player and glob.implants.arm_implant.ricochet:
				ricochet(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			do_damage(collider)
			if collider.has_method("piercing_damage"):
				collider.piercing_damage(damage[current_weapon], Vector3.ZERO, colpoint, global_transform.origin)
		timer.start(0.03)
		recoil += accuracy[current_weapon]
		

		if player:
			muzzle_light.light_energy = 1
			player_muzzle_flash.show()
			player_muzzle_flash.rotation.x = rand_range( - PI, PI)
			player_muzzle_flash.scale = Vector3(rand_range(0.2, 0.5), rand_range(0.2, 0.5), rand_range(0.2, 0.5))
			get_parent().rotation.x -= rand_range(0, 0.01)
			glob.player.reticle.shoot()
			
			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])
		else :
			if get_parent().get_parent().muzzleflash:
				get_parent().get_parent().muzzleflash.show()
		audio[current_weapon].play()
		audio[current_weapon].pitch_scale = float(magazine_ammo[current_weapon]) / MAX_MAG_AMMO[current_weapon] + 0.4 + rand_range( - 0.1, 0.1)
		magazine_ammo[current_weapon] -= 1

func blackjack()->void :
	if timer.is_stopped():
		timer.start(0.4)
		anim.play(FIRE_ANIM[current_weapon])
		
		
func blackjack_timeout():
	if current_weapon == W_BLACKJACK:
		if raycast.is_colliding():
			var col = raycast.get_collider()
			var col_p = raycast.get_collision_point()
			var col_n = (global_transform.origin + Vector3.DOWN - ($Front_Pos_Helper.global_transform.origin + Vector3.UP * 3)).normalized()
			if global_transform.origin.distance_to(col_p) < 3 and is_instance_valid(col):
				$Batonsound.play()
				glob.player.player_velocity += 5 * col_n
				glob.player.player_view.fov *= 1.02
				if col.has_method("tranq_timeout"):
					col.tranq_timeout(false)
				if col.has_method("add_velocity"):
					col.add_velocity(5, col_n)
	elif current_weapon == W_ROD:
		if fishing_hook != null:
			if fishing_hook.fish_caught:
				return 
			else :
				if is_instance_valid(fishing_hook):
					fishing_hook.queue_free()
				fishing_hook = null
		fishing_hook = HOOK.instance()
		glob.player.get_parent().add_child(fishing_hook)
		fishing_hook.global_transform.origin = global_transform.origin
		fishing_hook.velocity = - fish_strength * (global_transform.origin - $Front_Pos_Helper.global_transform.origin).normalized()
		fish_strength = 0

func mg3()->void :
	if timer.is_stopped():
		raycast.force_raycast_update()
		var rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
		if not player:
			rayrot += Vector3(rand_range( - enemy_accuracy, enemy_accuracy), rand_range( - enemy_accuracy, enemy_accuracy), 0)
		raycast.rotation = rayrot
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			var colpoint = raycast.get_collision_point()
			if player and glob.implants.arm_implant.ricochet:
				ricochet(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			decal(collider, colpoint, raycast.get_collision_normal())
			if collider.has_method("piercing_damage"):
				collider.piercing_damage(damage[current_weapon] / 2, Vector3.ZERO, colpoint, global_transform.origin)
			do_damage(collider)

			
			if not player and double_mg:
				yield (get_tree(), "idle_frame")
				var collider2 = raycast.get_collider()
				decal(collider2, raycast.get_collision_point(), raycast.get_collision_normal())
				do_damage(collider2)
				
		timer.start(0.04)
		
		
		recoil += accuracy[current_weapon]
		
		if player:
			muzzle_light.light_energy = 1
			get_parent().rotation.x -= rand_range(0, 0.01)
			player_weapon.rotation.z = 0 + rand_range( - 0.1, 0.1)
			glob.player.reticle.shoot()
			spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])
		else :
			if get_parent().get_parent().muzzleflash:
				get_parent().get_parent().muzzleflash.show()
		audio[current_weapon][0].play()
		
		

		magazine_ammo[current_weapon] -= 1

func silenced_smg()->void :
	if timer.is_stopped():
		raycast.force_raycast_update()
		var rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
		if not player:
			rayrot += Vector3(rand_range( - enemy_accuracy, enemy_accuracy), rand_range( - enemy_accuracy, enemy_accuracy), 0)
		raycast.rotation = rayrot
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if player and glob.implants.arm_implant.ricochet:
				ricochet(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			do_damage(collider)
			decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			do_damage(collider)
		timer.start(0.03)
		recoil += accuracy[current_weapon]
		
		if player:
			muzzle_light.light_energy = 1
			get_parent().rotation.x -= rand_range(0, 0.02)
			glob.player.reticle.shoot()
			spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])
		else :
			if get_parent().get_parent().muzzleflash:
				get_parent().get_parent().muzzleflash.show()
		audio[current_weapon].play()
		audio[current_weapon].pitch_scale = float(magazine_ammo[current_weapon]) / MAX_MAG_AMMO[current_weapon] + 0.4

		magazine_ammo[current_weapon] -= 1

func nailer()->void :
	if timer.is_stopped():
		raycast.force_raycast_update()
		var rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
		
			
		raycast.rotation = rayrot
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			var collision_p = raycast.get_collision_point()
			
				
			if collider.has_method("piercing_damage"):
				collider.piercing_damage(2, Vector3.ZERO, collision_p, global_transform.origin)
			do_damage(collider)

			flechette(collider)
		timer.start(0.01)
		recoil += accuracy[current_weapon]

		if player:
			muzzle_light.light_energy = 1
			
			get_parent().rotation.x -= rand_range(0, 0.002)
			glob.player.reticle.shoot()
			
			anim.stop()
			
		else :
			if get_parent().get_parent().muzzleflash:
				get_parent().get_parent().muzzleflash.show()
		audio[current_weapon].play()
		

		magazine_ammo[current_weapon] -= 1

func an_94()->void :
	if timer.is_stopped():
	
		timer.start(0.15)
		an94_internal()
		var burst_timer = Timer.new()
		add_child(burst_timer)
		burst_timer.wait_time = 0.04
		burst_timer.one_shot = true
		burst_timer.connect("timeout", self, "an94_internal")
		burst_timer.start()
		
		
		
		
		
		
		
	
	

func an94_internal():
		raycast.force_raycast_update()
		var rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
		if not player:
			rayrot += Vector3(rand_range( - enemy_accuracy, enemy_accuracy), rand_range( - enemy_accuracy, enemy_accuracy), 0)
		raycast.rotation = rayrot
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if player and glob.implants.arm_implant.ricochet:
				ricochet(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			do_damage(collider)
			decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			do_damage(collider)
		recoil += accuracy[current_weapon]
		
		if player:
			muzzle_light.light_energy = 1
			get_parent().rotation.x -= rand_range(0, 0.01)
			glob.player.reticle.shoot()
			spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)

			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])
		audio[current_weapon].play()
		

		magazine_ammo[current_weapon] -= 1

func ar()->void :
	if timer.is_stopped():

		timer.start(0.2)
		ar_internal()
		var burst_timer = Timer.new()
		add_child(burst_timer)
		burst_timer.wait_time = 0.05
		burst_timer.one_shot = true
		burst_timer.connect("timeout", self, "ar_internal")
		burst_timer.start()
		var burst_timer2 = burst_timer.duplicate()
		add_child(burst_timer2)
		burst_timer2.connect("timeout", self, "ar_internal")
		burst_timer2.wait_time = 0.1
		burst_timer2.start()
		
		
		
		
		
		
		
	
	

func ar_internal():
		raycast.force_raycast_update()
		var rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
		if not player:
			rayrot += Vector3(rand_range( - enemy_accuracy, enemy_accuracy), rand_range( - enemy_accuracy, enemy_accuracy), 0)
		raycast.rotation = rayrot
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if player and glob.implants.arm_implant.ricochet:
				ricochet(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			do_damage(collider)
			decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			do_damage(collider)
		recoil += accuracy[current_weapon]
		
		if player:
			muzzle_light.light_energy = 1
			get_parent().rotation.x -= rand_range(0, 0.02)
			glob.player.reticle.shoot()
			
		if not zoom_flag and player:
			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])
		audio[current_weapon].play()
		

		magazine_ammo[current_weapon] -= 1
func zippy()->void :
	if timer.is_stopped():
		var rand = randi() % 3
		if rand == 0:
			var rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
			if not player:
				rayrot += Vector3(rand_range( - enemy_accuracy, enemy_accuracy), rand_range( - enemy_accuracy, enemy_accuracy), 0)
			raycast.force_raycast_update()
			if raycast.is_colliding():
				var collider = raycast.get_collider()
				
				if player and glob.implants.arm_implant.ricochet:
					ricochet(collider, raycast.get_collision_point(), raycast.get_collision_normal())
				do_damage(collider)
				decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())
	
	
	
	
	
	
				do_damage(collider)
			if player:
				timer.start(0.07)
			else :
				timer.start(0.3)
				if get_parent().get_parent().muzzleflash:
					get_parent().get_parent().muzzleflash.show()
			
			if player:
				get_parent().rotation.x -= 0.01
				muzzle_light.light_energy = 1
				glob.player.reticle.shoot()
				spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin + Vector3.FORWARD * 0.2)
				anim.stop()
				anim.play(FIRE_ANIM[current_weapon])
	
				
			audio[current_weapon].play()
			audio[current_weapon].pitch_scale = float(magazine_ammo[current_weapon]) / MAX_MAG_AMMO[current_weapon] + 0.4
			magazine_ammo[current_weapon] -= 1
		elif rand == 1:
			timer.start(0.07)
			get_parent().rotation.x -= 0.1
			muzzle_light.light_energy = 1
			magazine_ammo[current_weapon] -= 1
			audio[current_weapon].play()
			glob.player.damage(5, Vector3.ZERO, global_transform.origin, global_transform.origin)
func pistol()->void :
	if timer.is_stopped():
		var rayrot = raycast.rotation
		if not leaning and player:
			rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
			raycast.rotation = rayrot
		if not player:
			rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
			rayrot += Vector3(rand_range( - enemy_accuracy, enemy_accuracy), rand_range( - enemy_accuracy, enemy_accuracy), 0)
			raycast.rotation = rayrot
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if player and glob.implants.arm_implant.ricochet:
				ricochet(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())






			do_damage(collider)
		if player:
			get_parent().rotation.x -= 0.01
			timer.start(0.07)
			player_muzzle_flash.show()
			player_muzzle_flash.scale = Vector3(rand_range(0.1, 0.1), rand_range(0.1, 0.1), rand_range(0.1, 0.1))
		else :
			timer.start(0.3)
			if get_parent().get_parent().muzzleflash:
				get_parent().get_parent().muzzleflash.show()
		
		if player:
			muzzle_light.light_energy = 1
			glob.player.reticle.shoot()
			spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])

			
		audio[current_weapon].play()
		audio[current_weapon].pitch_scale = float(magazine_ammo[current_weapon]) / MAX_MAG_AMMO[current_weapon] + 0.4
		magazine_ammo[current_weapon] -= 1


func vag72()->void :
	if timer.is_stopped():
		var rayrot = raycast.rotation
		rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
		raycast.rotation = rayrot
		if not player:
			rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
			rayrot += Vector3(rand_range( - enemy_accuracy, enemy_accuracy), rand_range( - enemy_accuracy, enemy_accuracy), 0)
			raycast.rotation = rayrot
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if player and glob.implants.arm_implant.ricochet:
				ricochet(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())






			do_damage(collider)
		if player:
			get_parent().rotation.x -= 0.01
			timer.start(0.07)
			player_muzzle_flash.show()
			player_muzzle_flash.scale = Vector3(rand_range(1, 1), rand_range(1, 1), rand_range(1, 1))
		else :
			timer.start(0.3)
			if get_parent().get_parent().muzzleflash:
				get_parent().get_parent().muzzleflash.show()
		
		if player:
			muzzle_light.light_energy = 1
			glob.player.reticle.shoot()
			spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])

			
		audio[current_weapon].play()
		
		magazine_ammo[current_weapon] -= 1

func sks()->void :
	if timer.is_stopped():
		var rayrot = raycast.rotation
		rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
		raycast.rotation = rayrot
		
			
			
			
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if player and glob.implants.arm_implant.ricochet:
				ricochet(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())






			var dmg = 0
			if Global.STOCKS.total_assets < 100:
				dmg = 1
			elif Global.STOCKS.total_assets < 1000:
				dmg = 20
			elif Global.STOCKS.total_assets < 10000:
				dmg = 50
			elif Global.STOCKS.total_assets < 100000:
				dmg = 100
			elif Global.STOCKS.total_assets < 1000000:
				dmg = 150
			else :
				dmg = 20000
				$SKS_Sound2.play()
			damage[current_weapon] = dmg
			print(damage[current_weapon])
			do_damage(collider)
		if player:
			get_parent().rotation.x -= 0.01
			timer.start(0.07)
			player_muzzle_flash.show()
			player_muzzle_flash.scale = Vector3(rand_range(1, 1), rand_range(1, 1), rand_range(1, 1))
		else :
			timer.start(0.3)
			if get_parent().get_parent().muzzleflash:
				get_parent().get_parent().muzzleflash.show()
		
		if player:
			muzzle_light.light_energy = 1
			glob.player.reticle.shoot()
			spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])
			magazine_ammo[current_weapon] -= 1

			
		$SKS_Sound.play()
		
		

func skullgun()->void :
	if timer.is_stopped():
		timer.start(0.4)
		skullgun_internal()
		yield (get_tree().create_timer(0.1), "timeout")
		skullgun_internal()
		yield (get_tree().create_timer(0.1), "timeout")
		skullgun_internal()
		
func skullgun_internal():
		raycast.rotation = raycast_init_rot + Vector3(rand_range( - accuracy[0], accuracy[0]), 
										rand_range( - accuracy[0], accuracy[0]), raycast_init_rot.z)
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())






			var new_explosion = explosion.instance()
			glob.player.get_parent().add_child(new_explosion)
			new_explosion.global_transform.origin = raycast.get_collision_point()
		
		if player:
			glob.player.damage(2, Vector3.ZERO, global_transform.origin, global_transform.origin)
			get_parent().rotation.x -= 0.04
			muzzle_light.light_energy = 1
			glob.player.reticle.shoot()
			
			
			
		audio[0].play()
		


func nambu()->void :
	if timer.is_stopped():
		
		var rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
		if not player:
			rayrot += Vector3(rand_range( - enemy_accuracy, enemy_accuracy), rand_range( - enemy_accuracy, enemy_accuracy), 0)
		raycast.rotation = rayrot
		magazine_ammo[current_weapon] -= 1
		if player:
			timer.start(1)
		else :
			timer.start(1)
		
		if player:
			
			
			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])
			var shoot_timer = Timer.new()
			add_child(shoot_timer)
			shoot_timer.wait_time = 0.5
			shoot_timer.one_shot = true
			shoot_timer.connect("timeout", self, "nambu_fire")
			shoot_timer.start()
			return 
		raycast.force_raycast_update()
		if raycast.is_colliding() and not player:
			var collider = raycast.get_collider()
			decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			do_damage(collider)

		if player:
			get_parent().rotation.x -= 0.1
		audio[current_weapon].play()
		audio[current_weapon].pitch_scale = float(magazine_ammo[current_weapon]) / MAX_MAG_AMMO[current_weapon] + 0.4
		
		
	
func nambu_fire():
		if current_weapon != W_NAMBU:
			return 
		$OmniLight.light_energy = 1
		glob.player.reticle.shoot()
		player_muzzle_flash.show()
		player_muzzle_flash.scale = Vector3(2, 2, 2)
		for body in alert.get_overlapping_bodies():
			if body.has_method("alert"):
				body.alert(global_transform.origin)
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if player:
				ricochet(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			do_damage(collider)
			decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())
			do_damage(collider)
		if player:
			get_parent().rotation.x -= 0.1
		audio[current_weapon].play()
		audio[current_weapon].pitch_scale = float(magazine_ammo[current_weapon]) / MAX_MAG_AMMO[current_weapon] + 0.4
	
func shoot_through(collider, collision_p):
	if collider.has_method("damage"):
		through_count += 1
		if through_count > 6:
			return 
		var new_raycast = raycast.duplicate()
				
		get_parent().get_parent().get_parent().add_child(new_raycast)
		new_raycast.global_transform.origin = collision_p
		new_raycast.transform.basis = get_parent().transform.basis * get_parent().get_parent().transform.basis
		new_raycast.force_raycast_update()
		if new_raycast.is_colliding():
			var new_collider = new_raycast.get_collider()
			if new_collider.has_method("damage"):
				shoot_through(new_collider, new_raycast.get_collision_point())

			decal(new_collider, new_raycast.get_collision_point(), new_raycast.get_collision_normal())
			do_damage(new_collider)
			new_raycast.queue_free()
			
func ricochet(collider, collision_p, collision_n, ricochet_count = 0, last_collision_p = global_transform.origin):
		if collider.has_method("damage") or not is_instance_valid(collider):
			return 
		
		
		
		var new_raycast = raycast.duplicate()
		new_raycast.set_collision_mask_bit(1, 1)
		get_parent().get_parent().get_parent().add_child(new_raycast)
		new_raycast.global_transform.origin = collision_p
		var bounce = new_raycast.global_transform.origin + ((last_collision_p - collision_p).normalized()).bounce(collision_n).normalized() * 50
		new_raycast.look_at(bounce, Vector3.UP)
		new_raycast.force_raycast_update()
		last_collision_p = collision_p
		if new_raycast.is_colliding():
			collision_p = new_raycast.get_collision_point()
			collision_n = new_raycast.get_collision_normal()
			var new_collider = new_raycast.get_collider()
			if ricochet_count < 1:
				ricochet_count += 1
				ricochet(new_collider, collision_p, collision_n, ricochet_count, last_collision_p)
				
			
			

			decal(new_collider, new_raycast.get_collision_point(), new_raycast.get_collision_normal())
			do_damage(new_collider)
			new_raycast.queue_free()


func sniper()->void :
	if timer.is_stopped():
		if not player:
			if raycast.is_colliding():
				if raycast.get_collider() == glob.player:
					glob.player.UI.set_sniped(true)
		var rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
		raycast.rotation = rayrot
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			var colpoint = raycast.get_collision_point()
			shoot_through(collider, raycast.get_collision_point())
			flechette(collider)
			do_damage(collider)
			if collider.has_method("piercing_damage"):
				collider.piercing_damage(damage[current_weapon] * 2, Vector3.ZERO, colpoint, global_transform.origin)
		if player:
			$OmniLight.light_energy = 1
			if $Sniper_Tracer_Ray.is_colliding():
				var collider = $Sniper_Tracer_Ray.get_collider()
				for i in range(int(clamp($Sniper_Barrel_End.global_transform.origin.distance_to($Sniper_Tracer_Ray.get_collision_point()), 0, 100) * 2)):
					var pos = $Sniper_Barrel_End.global_transform.origin - ($Sniper_Barrel_End.global_transform.origin - $Sniper_Tracer_Ray.get_collision_point()).normalized() * i / 2
					
					pos += Vector3(sin(i + t) * 0.2, cos(i + t) * 0.2, sin(i + t) * 0.2)
					
		timer.start(RELOAD_TIME[current_weapon])
		
		if player:
			glob.player.reticle.shoot()
			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])
		
		audio[current_weapon].play()
		
		magazine_ammo[current_weapon] -= 1
		if player:
			yield (get_tree().create_timer(0.1), "timeout")
			zoom_flag = false
			yield (get_tree().create_timer(0.9), "timeout")
		
			spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
		
	
	

func mauser()->void :
	if not player:
		if raycast.is_colliding():
			if raycast.get_collider() == glob.player:
				glob.player.UI.set_sniped(true)
	if timer.is_stopped():
		if player:
			timer.start(1)
			$OmniLight.light_energy = 1
			var rayrot = Vector3(rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), rand_range( - (recoil + leaning_modifier), recoil + leaning_modifier), raycast_init_rot.z)
			raycast.rotation = rayrot
			raycast.force_raycast_update()
			if raycast.is_colliding():
				var collider = raycast.get_collider()
				if player and glob.implants.arm_implant.ricochet:
					ricochet(collider, raycast.get_collision_point(), raycast.get_collision_normal())
				shoot_through(collider, raycast.get_collision_point())
				decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())
				do_damage(collider)
				
			
				
				
				
					
					
					
					
		else :
			if raycast.is_colliding():
				var collider = raycast.get_collider()
				decal(collider, raycast.get_collision_point(), raycast.get_collision_normal())
				do_damage(collider)
			timer.start(2)
		
		if player:
			glob.player.reticle.shoot()
			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])
		
		audio[current_weapon].play()
		audio[current_weapon].pitch_scale = float(magazine_ammo[current_weapon]) / MAX_MAG_AMMO[current_weapon]
		magazine_ammo[current_weapon] -= 1
		if player:
			yield (get_tree().create_timer(0.2), "timeout")
			zoom_flag = false
			yield (get_tree().create_timer(0.5), "timeout")
			spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
		
	
	
func shock()->void :
	if timer.is_stopped():
		randomize()

		for i in range(40):
			raycast.rotation = raycast_init_rot + Vector3(rand_range( - accuracy[current_weapon] - leaning_modifier, accuracy[current_weapon] + leaning_modifier), 
											rand_range( - accuracy[current_weapon] - leaning_modifier, accuracy[current_weapon] + leaning_modifier), raycast_init_rot.z)
			raycast.force_raycast_update()
			if raycast.is_colliding():
				raycast.force_raycast_update()
				var collider = raycast.get_collider()
				flechette(collider)
				do_damage(collider)
		timer.start(0.01)
		if player:
			get_parent().rotation.x -= 0.3
			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])
		audio[current_weapon].play()
		audio[current_weapon].pitch_scale = float(magazine_ammo[current_weapon]) / MAX_MAG_AMMO[current_weapon] + 0.4
		magazine_ammo[current_weapon] -= 1
		
		if player:
			$OmniLight.light_energy = 1
			glob.player.reticle.shoot()
			spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
		
func shotgun()->void :
	if timer.is_stopped():
		randomize()

		for i in range(12):
			raycast.rotation = raycast_init_rot + Vector3(rand_range( - accuracy[current_weapon] - leaning_modifier, accuracy[current_weapon] + leaning_modifier), 
											rand_range( - accuracy[current_weapon] - leaning_modifier, accuracy[current_weapon] + leaning_modifier), raycast_init_rot.z)
			raycast.force_raycast_update()
			if raycast.is_colliding():
				raycast.force_raycast_update()
				var collider = raycast.get_collider()
				flechette(collider)
				do_damage(collider)
		timer.start(0.7)
		if player:
			get_parent().rotation.x -= 0.1
			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])
		audio[current_weapon].play()
		audio[current_weapon].pitch_scale = float(magazine_ammo[current_weapon]) / MAX_MAG_AMMO[current_weapon] + 0.4
		magazine_ammo[current_weapon] -= 1
		
		if player:
			$OmniLight.light_energy = 1
			glob.player.reticle.shoot()
			yield (get_tree().create_timer(0.5), "timeout")
			spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
		
	

func autoshotgun()->void :
	if timer.is_stopped():
		randomize()

		for i in range(12):
			raycast.rotation = raycast_init_rot + Vector3(rand_range( - accuracy[current_weapon] - leaning_modifier, accuracy[current_weapon] + leaning_modifier), 
											rand_range( - accuracy[current_weapon] - leaning_modifier, accuracy[current_weapon] + leaning_modifier), raycast_init_rot.z)
			raycast.force_raycast_update()
			if raycast.is_colliding():
				raycast.force_raycast_update()
				var collider = raycast.get_collider()
				flechette(collider)
				do_damage(collider)
		timer.start(0.15)
		if player:
			get_parent().rotation.x -= 0.05
			anim.stop()
			$OmniLight.light_energy = 1
			anim.play(FIRE_ANIM[current_weapon])
		audio[current_weapon].play()
		
		magazine_ammo[current_weapon] -= 1
		
		if player:
			glob.player.reticle.shoot()
		if player:
			spawn_shell(SHELLS[current_weapon], 1, 10, get_parent().get_parent().transform.basis.xform(Vector3(5, - 10, 0).normalized()), $Player_Weapon / ShellPosition.global_transform.origin)
		
	


func rocket_launcher()->void :
		if timer.is_stopped():
			var missile_new = BULLETS.instance()
			
			randomize()
			var randName = int(rand_range(0,1000000))
			missile_new.set_name(missile_new.name + "#" + str(randName))
			
			get_tree().get_nodes_in_group("Sync")[0].add_child(missile_new)
			missile_new.global_transform.origin = global_transform.origin
			missile_new.velocity = (global_transform.origin - $Front_Pos_Helper.global_transform.origin).normalized() * - 30
			
			rpc("_spawn_object","res://MOD_CONTENT/CruS Online/effects/fake_Missile_Kinematic.tscn",missile_new.name,missile_new.global_transform)
			
			timer.start(0.7)
			magazine_ammo[current_weapon] -= 1
			if player:
				anim.stop()
				anim.play(FIRE_ANIM[current_weapon])
				audio[current_weapon].play()
				glob.player.reticle.shoot()
			else :
				missile_new.set_collision_mask_bit(2, 0)
				missile_new.set_collision_mask_bit(1, 1)

func light()->void :
		if timer.is_stopped():
			var missile_new = LIGHT_BULLET.instance()
			if player:
				add_child(missile_new)
				missile_new.set_as_toplevel(true)
			else :
				get_parent().get_parent().get_parent().get_parent().add_child(missile_new)
			missile_new.global_transform.origin = $Player_Weapon / LIGHT / Position3D.global_transform.origin

			missile_new.velocity = ($Player_Weapon / LIGHT / Position3D.global_transform.origin - $Front_Pos_Helper.global_transform.origin).normalized() * - 60
			timer.start(0.1)
			magazine_ammo[current_weapon] -= 1
			if player:
				anim.stop()
				anim.play(FIRE_ANIM[current_weapon])
				audio[current_weapon].play()
				glob.player.reticle.shoot()
				get_parent().rotation.x -= rand_range(0, 0.03)
				player_weapon.rotation.z = 0 + rand_range( - 0.1, 0.1)
			else :
				missile_new.set_collision_mask_bit(2, 0)
				missile_new.set_collision_mask_bit(1, 1)

func gas()->void :
		if timer.is_stopped():
			
			var missile_new = GAS_GRENADE.instance()
			if player:
				zoom_flag = false
			get_tree().get_nodes_in_group("Sync")[0].add_child(missile_new)
			
			randomize()
			var randName = int(rand_range(0,1000000))
			missile_new.set_name(missile_new.name + "#" + str(randName))
			
			rpc("_spawn_object","res://MOD_CONTENT/CruS Online/effects/fake_Grenade.tscn",missile_new.name,missile_new.global_transform)
			
			if player:
				missile_new.set_collision_mask_bit(1, 0)
			else :
				missile_new.set_collision_mask_bit(1, 1)
				missile_new.set_collision_mask_bit(2, 0)
			missile_new.global_transform.origin = global_transform.origin
			missile_new.add_collision_exception_with(get_parent().get_parent())
			missile_new.set_velocity(60, (global_transform.origin - $Front_Pos_Helper.global_transform.origin).normalized(), global_transform.origin)
			timer.start(3)
			
			audio[current_weapon].play()
			if player:
				magazine_ammo[current_weapon] -= 1
				anim.stop()
				anim.play(FIRE_ANIM[current_weapon])
				
				glob.player.reticle.shoot()
func flamethrower():
		if timer.is_stopped():
			timer.start(0.025)
			magazine_ammo[current_weapon] -= 1
			var missile_new = FIRE.instance()
			if player:
				get_parent().get_parent().get_parent().add_child(missile_new)
			else :
				get_parent().get_parent().get_parent().get_parent().add_child(missile_new)
			if player:
				missile_new.set_collision_mask_bit(1, 0)
			else :
				missile_new.set_collision_mask_bit(1, 1)
				missile_new.set_collision_mask_bit(2, 0)
			missile_new.global_transform.origin = player_muzzle_flash.global_transform.origin
			
			missile_new.velocity = - (global_transform.origin - $Front_Pos_Helper.global_transform.origin).normalized() * 40
			missile_new.velocity += Global.player.player_velocity
func bore()->void :
		if timer.is_stopped():
			var missile_new = BORE.instance()
			zoom_flag = false
			get_parent().get_parent().get_parent().add_child(missile_new)
			missile_new.set_collision_mask_bit(1, 0)
			missile_new.global_transform.origin = global_transform.origin
			missile_new.set_velocity(30, (global_transform.origin - $Front_Pos_Helper.global_transform.origin).normalized(), global_transform.origin)
			timer.start(2)
			
			glob.player.damage(10, Vector3.ZERO, global_transform.origin, global_transform.origin)
			anim.stop()
			anim.play(FIRE_ANIM[current_weapon])
			audio[current_weapon].play()
			glob.player.reticle.shoot()
func radiator()->void :
	audio[current_weapon].pitch_scale = clamp(cylinder_velocity * 10 + 0.01, 2.0, 4)
	if not audio[current_weapon].playing:
		audio[current_weapon].play()
	cylinder_velocity += 0.005
	
	if cylinder_velocity < 0.1:
		return 
	if timer.is_stopped():
		$Rad_Sound2.play()
		timer.start(0.8)
		$Radiation_Area / MeshInstance.scale.z = 1
		$Radiation_Area / MeshInstance.scale.x = 1
		$Radiation_Area / MeshInstance.show()
		
		for r in range(6):
			var rad_new = RADIATION.instance()
			
			randomize()
			var randName = int(rand_range(0,1000000))
			rad_new.set_name(rad_new.name + "#" + str(randName))
			
			get_tree().get_nodes_in_group("Sync")[0].add_child(rad_new)
			rad_new.global_transform.origin = global_transform.origin + - (global_transform.origin - $Front_Pos_Helper.global_transform.origin).normalized() * (r + 4)
			
			rpc("_spawn_object","res://MOD_CONTENT/CruS Online/effects/fake_Radiation.tscn",rad_new.name,rad_new.global_transform)
		for b in $Radiation_Area.get_overlapping_bodies():
			if b.has_method("damage"):
				b.damage(50, (global_transform.origin - $Front_Pos_Helper.global_transform.origin).normalized(), b.global_transform.origin, global_transform.origin)
func tranq()->void :
	if timer.is_stopped():
			
			var missile_new = TRANQ_DART.instance()
			DART_mesh.get_node("Particles").emitting = true
			if player:
				get_parent().get_parent().get_parent().add_child(missile_new)
			else :
				get_parent().get_parent().get_parent().get_parent().add_child(missile_new)
			if player:
				missile_new.set_collision_mask_bit(1, 0)
			else :
				missile_new.set_collision_mask_bit(1, 1)
				missile_new.set_collision_mask_bit(2, 0)
			missile_new.global_transform.origin = global_transform.origin
			missile_new.set_velocity(90, (global_transform.origin - $Front_Pos_Helper.global_transform.origin).normalized(), global_transform.origin)
			
			
			audio[current_weapon].play()
			if player:
				magazine_ammo[current_weapon] -= 1
				anim.stop()
				anim.play(FIRE_ANIM[current_weapon])
				
				glob.player.reticle.shoot()
	

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


func AI_shoot()->void :
	if current_weapon == null or disabled:
		return 
	if magazine_ammo[current_weapon] > 0 and reload_timer.is_stopped():
		if not player:
			recoil = 0
			glob.action_lerp_value += 1
		shoot()
func alt_fire()->void :
	if player:
		
			
		zoom()

func zoom():
	if player:
		zoom_flag = not zoom_flag

func shoot()->void :
	rotation.x = initrot.x
	if magazine_ammo[current_weapon] > 0 and player and current_weapon != W_TRANQ and current_weapon != W_BLACKJACK and current_weapon != W_PISTOL and timer.is_stopped() and current_weapon != W_SILENCED_SMG and current_weapon != W_MAUSER and current_weapon != W_NAMBU and current_weapon != W_RADIATOR and current_weapon != W_FLASHLIGHT and current_weapon != W_CANCER and current_weapon != W_ROD and current_weapon != W_NAILER:
		
		for body in nearby:
			if body.has_method("alert"):
				body.alert(global_transform.origin)
			
	match current_weapon:
		W_STEYR:
			steyr()
		W_FLASHLIGHT:
			if Input.is_action_just_pressed("mouse_1") and player:
				flash_light_switch = not flash_light_switch
		W_PISTOL:
			if Input.is_action_just_pressed("mouse_1") and player:
				pistol()
			elif not player:
				pistol()
		W_SMG:
			smg()
		W_AR:
			if Input.is_action_just_pressed("mouse_1") and player:
				ar()
			elif not player:
				ar()
		W_AN94:
			if Input.is_action_just_pressed("mouse_1") and player:
				an_94()
			elif not player:
				an_94()
		W_MKR:
			mkr()
		W_SHOTGUN:
			if Input.is_action_just_pressed("mouse_1") and player:
				shotgun()
			elif not player:
				shotgun()
		W_SHOCK:
			if Input.is_action_just_pressed("mouse_1") and player:
				shock()
			elif not player:
				shock()
		W_ROCKET_LAUNCHER:
			rocket_launcher()
		W_GAS:
			gas()
		W_BLACKJACK:
			if Input.is_action_just_pressed("mouse_1"):
				blackjack()
				
		W_SNIPER:
			if Input.is_action_just_pressed("mouse_1") and player:
				sniper()
			else :
				sniper()
		W_MAUSER:
			if player:
				if Input.is_action_just_pressed("mouse_1"):
					mauser()
			else :
				mauser()
		W_SILENCED_SMG:
			silenced_smg()
		W_NAMBU:
			if Input.is_action_just_pressed("mouse_1") and player:
				nambu()
			elif not player:
				nambu()
		W_MG3:
			mg3()
		W_AUTOSHOTGUN:
			autoshotgun()
		W_BORE:
			if Input.is_action_just_pressed("mouse_1") and player:
				bore()
		W_RADIATOR:
			radiator()
		W_TRANQ:
			if Input.is_action_just_pressed("mouse_1") and player:
				tranq()
		W_ZIPPY:
			if Input.is_action_just_pressed("mouse_1") and player:
				zippy()
		W_VAG72:
			if Input.is_action_just_pressed("mouse_1") and player:
				vag72()
			elif not player:
				vag72()
		W_LIGHT:
			light()
		W_SKS:
			if Input.is_action_just_pressed("mouse_1") and player:
				sks()
			elif not player:
				sks()
		W_CANCER:
			if Input.is_action_just_pressed("mouse_1") and player:
				cancer()
			elif not player:
				cancer()
		W_ROD:
			if Input.is_action_just_pressed("mouse_1"):
				blackjack()
				if fishing_hook != null:
					if fishing_hook.fish_caught:
						fishing_hook.return_fish = true
					else :
						if is_instance_valid(fishing_hook):
							fishing_hook.queue_free()
						fishing_hook = null
		W_FLAMETHROWER:
			flamethrower()
			if not audio[current_weapon].playing:
				if Input.is_action_pressed("mouse_1"):
					audio[current_weapon].play()
		W_NAILER:
			nailer()
	set_UI_ammo()

func do_damage(collider:Spatial)->void :
	if not is_instance_valid(collider):
		return 
	if collider.has_method("damage"):
		var col_p = raycast.get_collision_point()
		if current_weapon != null:
			collider.damage(damage[current_weapon], - global_transform.origin.direction_to(col_p), col_p, global_transform.origin)
		else :
			collider.damage(damage[0], raycast.get_collision_normal(), col_p, global_transform.origin)
		damage_particle(collider, col_p)
		if player:
			glob.player.reticle.hit()
		

func flechette(collider:Spatial)->void :
	if collider.get_collision_layer_bit(0):
		var decal_new
		decal_new = DECALS[current_weapon].instance()
		collider.add_child(decal_new)
		
		decal_new.global_transform.origin = raycast.get_collision_point()
		decal_new.look_at((global_transform.origin), Vector3.UP)
		if current_weapon == W_SNIPER:
			decal_new.scale = Vector3(3, 3, 3)

func decal(collider:Spatial, c_point, c_normal)->void :
	if not is_instance_valid(collider):
		return 
	if collider.get_collision_layer_bit(0) == true:
		var decal_new
		if current_weapon != null:
			decal_new = DECALS[current_weapon].instance()
		else :
			decal_new = DECALS[0].instance()
		collider.add_child(decal_new)
		decal_new.global_transform.basis = align_up(decal_new.global_transform.basis, c_normal)
		decal_new.global_transform.origin = c_point + c_normal * 1e-08
		
func spawn_shell(shell:PackedScene, count:int, speed:float, collision_n:Vector3, collision_p:Vector3):
	if Global.fps < 30:
		return 
	for i_shell in range(count):
		if shell != null:
			var new_shell = shell.instance()
			new_shell.isClientOnly = true
			get_parent().get_parent().get_parent().add_child(new_shell)
			new_shell.global_transform.origin = collision_p
			new_shell.damage(speed, collision_n + Vector3(rand_range(0, 0.1), rand_range(0, 0.1), rand_range(0, 0.1)), collision_p, Vector3.ZERO)

func set_UI_ammo():
	if player and current_weapon != null:
		UI.set_ammo(ammo[current_weapon], magazine_ammo[current_weapon], MAX_MAG_AMMO[current_weapon], MAX_AMMO[current_weapon])

func set_weapon(weapon_index):
	
	
	if player and not orb:
		
		anim.stop()
		if current_weapon == weapon1:
			weapon1 = weapon_index
		elif current_weapon == weapon2:
			weapon2 = weapon_index
		current_weapon = weapon_index
		anim.stop()
		anim.play("Nogun", - 1, 100)
		glob.player.set_move_speed()
		UI.set_ammo(ammo[current_weapon], magazine_ammo[current_weapon], MAX_MAG_AMMO[current_weapon], MAX_AMMO[current_weapon])

func add_ammo(amount:int, type:int, ammobox:Spatial):

	ammo[type] += amount



	if amount > 0:
		UI.notify("(" + str(amount) + ") " + W_NAMES[type] + " ammo received", Color(0, 1, 1))




	if current_weapon != null:
		UI.set_ammo(ammo[current_weapon], magazine_ammo[current_weapon], MAX_MAG_AMMO[current_weapon], MAX_AMMO[current_weapon])

func damage_particle(collider, position):
	if not collider.has_method("damage"):
		return 
	if collider.get_type() == T_FLESH:
		particle(P_BLOOD, collider, position)
		particle(P_BLOOD_2, collider, position)
	if collider.get_type() == T_ENVIRONMENT:
		particle(P_SPARK, collider, position)

func particle(particle, collider, position):
	var new_particle = particle.instance()
	collider.add_child(new_particle)
	new_particle.global_transform.origin = position
	new_particle.rotation.y = rand_range( - PI, PI)
	new_particle.rotation.x = rand_range( - PI, PI)
	new_particle.rotation.z = rand_range( - PI, PI)
	new_particle.emitting = true
