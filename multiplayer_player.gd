extends Spatial

var weaponsMesh
var currentWeaponId = 0

var weaponHold = false
var playerCrouch = false
var playerOnFloor = true

var playerMovement
var playerAim

var jumpBlend = 0.0
var movementBlend = [0.0,0.0]
var weaponBlend = 0.0
var playerAimBlend = 0.0
var crouchBlend

var death = false

var skinPath = "res://Textures/Misc/mainguy_clothes.png"
var nickname = "MT Foxtrot"
var color = "ff0000"

var transform_lerp : Transform

onready var animTree = $Puppet/PlayerModel/AnimTree

onready var Multiplayer = Global.get_node("Multiplayer")
onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")
onready var SteamInit = Global.get_node("Multiplayer/NetworkBridge")

var canDamage = false

var grapple_pos = null

onready var grapple_point = $GrapplePoint
onready var grapple_start_point = $Puppet/GrappleStartPoint

onready var grapple_orb = preload("res://Entities/grappleorb.tscn")
var grapple_orbs = []

func _ready():
	NetworkBridge.register_rpcs(self, [
		["_update_puppet", NetworkBridge.PERMISSION.ALL],
		["respawn_puppet", NetworkBridge.PERMISSION.ALL],
		["set_current_weapon", NetworkBridge.PERMISSION.ALL],
		["_set_toxic", NetworkBridge.PERMISSION.ALL],
		["_set_cancer", NetworkBridge.PERMISSION.ALL],
		["_do_damage", NetworkBridge.PERMISSION.ALL],
		["_drop_weapon", NetworkBridge.PERMISSION.ALL],
		["_set_fire", NetworkBridge.PERMISSION.ALL],
		["_set_death", NetworkBridge.PERMISSION.ALL],
		["set_is_on_floor", NetworkBridge.PERMISSION.ALL],
		["set_kick", NetworkBridge.PERMISSION.ALL],
		["set_crouch", NetworkBridge.PERMISSION.ALL],
		["set_gravity", NetworkBridge.PERMISSION.ALL],
		["shoot_commit", NetworkBridge.PERMISSION.ALL],
		["_respawn_player", NetworkBridge.PERMISSION.ALL],
		["hideHelpLabel", NetworkBridge.PERMISSION.ALL],
		["_set_tranquilize", NetworkBridge.PERMISSION.ALL]
	])
	
	weaponsMesh = $Puppet/PlayerModel/Armature/Skeleton/RightHand/Weapons.get_children()
	var skinMaterial = SpatialMaterial.new()
	skinMaterial.albedo_texture = load(skinPath)
	$Puppet/PlayerModel/Armature/Skeleton/Torso_Mesh.material_override = skinMaterial
	$Puppet/PlayerModel/Nickname.text = nickname
	$Puppet/PlayerModel/Nickname.modulate = Color(color)
	
#	Multiplayer.connect("host_tick", self, "host_tick")
	
	rset_config("transform_lerp", MultiplayerAPI.RPC_MODE_REMOTE)
	
	print(int(self.name))
	if int(self.name) == NetworkBridge.get_id():
		Multiplayer.playerPuppet = self
	
	canDamage = false
	$RespawnDamage.start()

remote func _set_death(id, recived_death):
	death = recived_death
	
	if death:
		animTree.set("parameters/DEATH1/active", true)
	else:
		animTree.set("parameters/DEATH1/active", false)
		animTree.active = true

func player_restart():
	$Puppet/PlayerModel/HelpLabel.hide()
	$Puppet/PlayerModel/Armature/Skeleton/Chest/Body.set_collision_layer_bit(8, false)
	$Puppet/PlayerModel/HelpTimer.stop()
	
	canDamage = false
	$RespawnDamage.start()

func play_death_sound():
	$Puppet/PlayerModel/SFX/IED1.play()
	$Puppet/PlayerModel/SFX/IED2.play()
	$Puppet/PlayerModel/SFX/IED_alert.play()

func play_explosion_sound():
	$Puppet/PlayerModel/SFX/IED_explosion.play()
	$Puppet/PlayerModel/SFX/IED_alert.stop()
	$Puppet/PlayerModel/SFX/IED1.stop()
	$Puppet/PlayerModel/SFX/IED2.stop()
	$Puppet/PlayerModel/SFX/IED_alert.pitch_scale = 1
	
	animTree.set("parameters/DEATH1/active", true)
	
	if not Multiplayer.hostSettings.canRespawn:
		$Puppet/PlayerModel/HelpTimer.wait_time = Multiplayer.hostSettings.helpTimer
		
		$Puppet/PlayerModel/HelpLabel.show()
		$Puppet/PlayerModel/HelpTimer.start()

func can_respawn():
	$Puppet/PlayerModel/HelpLabel.text = "Press [Use] to help"
	$Puppet/PlayerModel/Armature/Skeleton/Chest/Body.set_collision_layer_bit(8, true)

func _process(delta):
	weaponBlend = lerp(weaponBlend,float(!weaponHold),0.1)
	crouchBlend = lerp(crouchBlend,floor(playerCrouch),0.1)
	jumpBlend = lerp(jumpBlend,abs(floor(playerOnFloor) - 1),0.1)
	
	movementBlend[0] = lerp(movementBlend[0],playerMovement[0],0.1)
	movementBlend[1] = lerp(movementBlend[1],playerMovement[1],0.1)
	playerAimBlend = lerp(playerAimBlend,playerAim,0.1)
	
	animTree.set("parameters/LEGS_BLEND/blend_amount",jumpBlend)
	animTree.set("parameters/STANDMOVE_AMOUNT/blend_amount", movementBlend[0] * -1)
	animTree.set("parameters/CROUCHMOVE_AMOUNT/blend_amount", movementBlend[0] * -1)
	animTree.set("parameters/RUN_FORWARD_DIRECTION/blend_amount", movementBlend[1])
	animTree.set("parameters/RUN_BACKWARD_DIRECTION/blend_amount", movementBlend[1] * -1)
	animTree.set("parameters/MOVE_BLEND/blend_amount",crouchBlend)
	animTree.set("parameters/LOOK_DIRECTION/blend_amount", playerAim)
	animTree.set("parameters/ARMS_BLEND/blend_amount", weaponBlend)
	
	global_transform = global_transform.interpolate_with(transform_lerp, delta * 10.0)
	
	if not $Puppet/PlayerModel/HelpTimer.is_stopped():
		$Puppet/PlayerModel/HelpLabel.text =  "Wait " + str(floor($Puppet/PlayerModel/HelpTimer.time_left * 10.0)/10.0) + " to help"
	
	if $Puppet/PlayerModel/SFX/IED_alert.playing:
		$Puppet/PlayerModel/SFX/IED_alert.pitch_scale += 0.025

func set_grapple_orbs():
	grapple_point.global_transform.origin = grapple_pos
	var distance = grapple_start_point.global_transform.origin.distance_to(grapple_point)
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
	for orb in grapple_orbs:
		var o_scale = (sin(Global.player.time * 2 - grapple_orbs.find(orb)) * 0.5 + 2) * 0.5
		orb.scale = Vector3(o_scale, o_scale, o_scale)
		orb.global_transform.origin = grapple_start_point.global_transform.origin - (grapple_start_point.global_transform.origin - grapple_point.global_transform.origin).normalized() * grapple_orbs.find(orb) / orb_res

func delete_grapple_orbs():
	for orb in grapple_orbs:
		orb.queue_free()
	grapple_orbs = []

func _physics_process(delta):
	if int(self.name) != NetworkBridge.get_id():
		if grapple_pos != null and not death:
			set_grapple_orbs()
		else:
			delete_grapple_orbs()
	
	if NetworkBridge.check_connection():
		if int(self.name) == NetworkBridge.get_id():
			NetworkBridge.n_rpc_unreliable(self, "_update_puppet", [Global.player.global_transform, [Global.player.cmd.forward_move,Global.player.cmd.right_move], Global.player.rotation_helper.rotation.x, grapple_pos])
			hide()

remote func _update_puppet(id, recivedTransform, recivedPlayerMovement, recivedPlayerAim, recived_grapple_pos = null):
	if int(self.name) != NetworkBridge.get_id():
		transform_lerp = recivedTransform
		playerMovement = recivedPlayerMovement
		playerAim = recivedPlayerAim
		
		grapple_pos = recived_grapple_pos
	
	if NetworkBridge.n_is_network_master(self):
		NetworkBridge.n_rpc_unreliable(self, "_update_puppet", [recivedTransform, recivedPlayerMovement, recivedPlayerAim, grapple_pos])

puppet func respawn_puppet(id):
	if int(self.name) == NetworkBridge.get_id():
		NetworkBridge.n_rpc(self, "respawn_puppet")
	else:
		animTree.set("parameters/DEATH1/active", false)
		animTree.active = true

puppet func set_current_weapon(id, value):
	if int(self.name) == NetworkBridge.get_id():
		NetworkBridge.n_rpc(self, "set_current_weapon", [value])
	else:
		if value == null:
			weaponHold = true
			weaponsMesh[currentWeaponId].hide()
		else:
			weaponHold = false
			weaponsMesh[currentWeaponId].hide()
			weaponsMesh[value].show()
			weaponsMesh[value].get_child(0).hide()
			currentWeaponId = value

puppet func set_is_on_floor(id, value):
	if int(self.name) == NetworkBridge.get_id():
		NetworkBridge.n_rpc(self, "set_is_on_floor", [value])
	else:
		playerOnFloor = value

puppet func set_kick(id):
	if int(self.name) == NetworkBridge.get_id():
		NetworkBridge.n_rpc(self, "set_kick")
	else:
		animTree.set("parameters/KICK/active", true)

remote func _set_cancer(id):
	Global.player.cancer()

puppet func set_crouch(id, value):
	if int(self.name) == NetworkBridge.get_id():
		NetworkBridge.n_rpc(self, "set_crouch", [value])
	else:
		playerCrouch = value

puppet func set_gravity(id, value):
	if int(self.name) == NetworkBridge.get_id():
		NetworkBridge.n_rpc(self, "set_gravity", [value])
	else:
		if value > 0:
			$Puppet/PlayerModel.rotation.z = deg2rad(0)
		else:
			$Puppet/PlayerModel.rotation.z = deg2rad(180)

func do_damage(damage, collision_n, collision_p, shooter_pos, weapon_type = null):
	if canDamage:
		NetworkBridge.n_rpc_id(self, int(self.name), "_do_damage", [damage, collision_n, collision_p, shooter_pos, weapon_type])

remote func _do_damage(id, damage, collision_n, collision_p, shooter_pos, weapon_type):
	Global.player.set_last_damager_id(id, weapon_type)
	Global.player.damage(damage, collision_n, collision_p, shooter_pos)

func set_tranquilize():
	NetworkBridge.n_rpc_id(self, int(self.name), "_set_tranquilize")

remote func _set_tranquilize(id):
	Global.player.set_tranquilize()

func set_grapple(recived_position):
	grapple_pos = recived_position

func set_toxic():
	NetworkBridge.n_rpc_id(self, int(self.name), "_set_toxic")

remote func _set_toxic(id):
	Global.player.set_toxic()

func set_cancer():
	NetworkBridge.n_rpc_id(self, int(self.name), "_set_cancer")

func drop_weapon():
	NetworkBridge.n_rpc_id(self, int(self.name), "_drop_weapon")

remote func _drop_weapon(id):
	Input.action_press("drop")

func set_fire(value):
	NetworkBridge.n_rpc_id(self, int(self.name), "_set_fire", [value])

remote func _set_fire(id, value):
	Global.player.fakeFire.emitting = value

func respawn_player():
	NetworkBridge.n_rpc_id(self, int(self.name), "_respawn_player")
	hideHelpLabel()
	NetworkBridge.n_rpc(self, "hideHelpLabel")

remote func _respawn_player(id):
	if Global.player.died:
		Global.get_node('DeathScreen').respawn()

remote func hideHelpLabel(id = null):
	$Puppet/PlayerModel/HelpSound.play()
	$Puppet/PlayerModel/HelpLabel.hide()
	
	canDamage = false
	$RespawnDamage.start()

func setup_puppet(id):
	$Puppet/PlayerModel/Armature/Skeleton/Chest/Body.set_meta("puppetId", id)

func shoot_play(pitch, soundId = 0):
	NetworkBridge.n_rpc(self, "shoot_commit", [pitch, soundId])

func flashlight(state):
	NetworkBridge.n_rpc(self, "set_flashlight", [state])

remote func set_flashlight(id, state):
	$Puppet/PlayerModel/Armature/Skeleton/RightHand/Weapons/Flashlight_Mesh/SpotLight.visible = state

remote func shoot_commit(id, pitch, soundId):
	weaponsMesh[currentWeaponId].get_child(0).show()
	weaponsMesh[currentWeaponId].get_child(1 + soundId).pitch_scale = pitch
	weaponsMesh[currentWeaponId].get_child(1 + soundId).play()
	$FlashBuffer.start()

func flash_hide():
	weaponsMesh[currentWeaponId].get_child(0).hide()

func canDamageSet():
	canDamage = true
