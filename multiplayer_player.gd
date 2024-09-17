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

var skinPath = "res://Textures/Misc/mainguy_clothes.png"
var nickname = "MT Foxtrot"
var color = "ff0000"

var transform_lerp : Transform

onready var animTree = $Puppet/PlayerModel/AnimTree

onready var Multiplayer = Global.get_node("Multiplayer")

var canDamage = false

remote func _set_toxic():
	Global.player.set_toxic()

remote func _set_cancer():
	Global.player.cancer()

remote func _do_damage(damage, collision_n, collision_p, shooter_pos, weapon_type, damagerId):
	Global.player.set_last_damager_id(damagerId, weapon_type)
	Global.player.damage(damage, collision_n, collision_p, shooter_pos)

remote func _drop_weapon():
	Input.action_press("drop")

remote func _set_fire(value):
	Global.player.fakeFire.emitting = value

remote func _set_death(death):
	if death:
		animTree.set("parameters/DEATH1/active", true)
	else:
		animTree.set("parameters/DEATH1/active", false)
		animTree.active = true

func _ready():
	weaponsMesh = $Puppet/PlayerModel/Armature/Skeleton/RightHand/Weapons.get_children()
	var skinMaterial = SpatialMaterial.new()
	skinMaterial.albedo_texture = load(skinPath)
	$Puppet/PlayerModel/Armature/Skeleton/Torso_Mesh.material_override = skinMaterial
	$Puppet/PlayerModel/Nickname.text = nickname
	$Puppet/PlayerModel/Nickname.modulate = Color(color)
	
#	Multiplayer.connect("host_tick", self, "host_tick")
	
	rset_config("transform_lerp", MultiplayerAPI.RPC_MODE_REMOTE)
	
	if get_tree().network_peer != null and is_network_master():
		get_tree().get_nodes_in_group("Multiplayer")[0].playerPuppet = self
	
	canDamage = false
	$RespawnDamage.start()

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

func _physics_process(delta):
	Multiplayer.packages_count += 1
	
	if get_tree().network_peer != null and is_network_master():
		
		rpc_unreliable("_update_puppet",
			Global.player.global_transform,
			[Global.player.cmd.forward_move,Global.player.cmd.right_move],
			Global.player.rotation_helper.rotation.x
		)
		hide()

remote func _update_puppet(recivedTransform, recivedPlayerMovement, recivedPlayerAim):
	transform_lerp = recivedTransform
	playerMovement = recivedPlayerMovement
	playerAim = recivedPlayerAim

puppet func respawn_puppet():
	if is_network_master():
		rpc("respawn_puppet")
	else:
		animTree.set("parameters/DEATH1/active", false)
		animTree.active = true

puppet func set_current_weapon(value):
	if is_network_master():
		rpc("set_current_weapon", value)
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

puppet func set_is_on_floor(value):
	if is_network_master():
		rpc("set_is_on_floor", value)
	else:
		playerOnFloor = value

puppet func set_kick():
	if is_network_master():
		rpc("set_kick")
	else:
		animTree.set("parameters/KICK/active", true)

puppet func set_crouch(value):
	if is_network_master():
		rpc("set_crouch", value)
	else:
		playerCrouch = value

puppet func set_gravity(value):
	if is_network_master():
		rpc("set_gravity", value)
	else:
		if value > 0:
			$Puppet/PlayerModel.rotation.z = deg2rad(0)
		else:
			$Puppet/PlayerModel.rotation.z = deg2rad(180)

func do_damage(damage, collision_n, collision_p, shooter_pos, weapon_type = null):
	if canDamage:
		rpc_id(int(self.name),"_do_damage", damage, collision_n, collision_p, shooter_pos, weapon_type, get_tree().get_network_unique_id())

func set_toxic():
	rpc_id(int(self.name),"_set_toxic")

func set_cancer():
	rpc_id(int(self.name),"_set_cancer")

func drop_weapon():
	rpc_id(int(self.name),"_drop_weapon")

func set_fire(value):
	rpc_id(int(self.name),"_set_fire", value)

func respawn_player():
	rpc_id(int(self.name),"_respawn_player")
	hideHelpLabel()
	rpc("hideHelpLabel")

remote func _respawn_player():
	if Global.player.died:
		Global.get_node('DeathScreen').respawn()

remote func hideHelpLabel():
	$Puppet/PlayerModel/HelpSound.play()
	$Puppet/PlayerModel/HelpLabel.hide()
	
	canDamage = false
	$RespawnDamage.start()

func setup_puppet(id):
	$Puppet/PlayerModel/Armature/Skeleton/Chest/Body.set_meta("puppetId",id)

func shoot_play(pitch, soundId = 0):
	rpc("shoot_commit", pitch, soundId)

func flashlight(state):
	rpc("set_flashlight", state)

remote func set_flashlight(state):
	$Puppet/PlayerModel/Armature/Skeleton/RightHand/Weapons/Flashlight_Mesh/SpotLight.visible = state

remote func shoot_commit(pitch, soundId):
	weaponsMesh[currentWeaponId].get_child(0).show()
	weaponsMesh[currentWeaponId].get_child(1 + soundId).pitch_scale = pitch
	weaponsMesh[currentWeaponId].get_child(1 + soundId).play()
	$FlashBuffer.start()

func flash_hide():
	weaponsMesh[currentWeaponId].get_child(0).hide()

func canDamageSet():
	canDamage = true
