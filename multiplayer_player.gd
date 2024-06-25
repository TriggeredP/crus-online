extends Spatial

var weaponsMesh
var currentWeaponId = 0

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

remote func _set_toxic():
	Global.player.set_toxic()

remote func _do_damage(damage, collision_n, collision_p, shooter_pos, damagerId):
	Global.player.set_last_damager_id(damagerId)
	Global.player.damage(damage, collision_n, collision_p, shooter_pos)

remote func _drop_weapon():
	Input.action_press("drop")

remote func _set_death(death):
	if death:
		animTree.set("parameters/DEATH1/active", true)
	else:
		animTree.set("parameters/DEATH1/active", false)
		animTree.active = true

remote func _update_puppet(weaponId,playerIsDead,playerOnFloor,playerMovement,playerAim,playerKick,playerCrouch):
	jumpBlend = lerp(jumpBlend,abs(floor(playerOnFloor) - 1),0.1)
	movementBlend[0] = lerp(movementBlend[0],playerMovement[0],0.1)
	movementBlend[1] = lerp(movementBlend[1],playerMovement[1],0.1)
	playerAimBlend = lerp(playerAimBlend,playerAim,0.1)
	
	crouchBlend = lerp(crouchBlend,floor(playerCrouch),0.1)
	
	animTree.set("parameters/LEGS_BLEND/blend_amount",jumpBlend)
	
	animTree.set("parameters/STANDMOVE_AMOUNT/blend_amount", movementBlend[0] * -1)
	animTree.set("parameters/CROUCHMOVE_AMOUNT/blend_amount", movementBlend[0] * -1)
	
	animTree.set("parameters/RUN_FORWARD_DIRECTION/blend_amount", movementBlend[1])
	animTree.set("parameters/RUN_BACKWARD_DIRECTION/blend_amount", movementBlend[1] * -1)
	
	animTree.set("parameters/MOVE_BLEND/blend_amount",crouchBlend)
	
	animTree.set("parameters/LOOK_DIRECTION/blend_amount", playerAim)
	
	if playerKick:
		animTree.set("parameters/KICK/active", true)
	
	if not playerIsDead:
		animTree.set("parameters/DEATH1/active", false)
		animTree.active = true
	
	if weaponId == null:
		weaponBlend = lerp(weaponBlend,0,0.1)
		weaponsMesh[currentWeaponId].hide()
	else:
		weaponBlend = lerp(weaponBlend,1,0.1)
		weaponsMesh[currentWeaponId].hide()
		weaponsMesh[weaponId].show()
		weaponsMesh[weaponId].get_child(0).hide()
		currentWeaponId = weaponId
	
	animTree.set("parameters/ARMS_BLEND/blend_amount", weaponBlend)

func _ready():
	weaponsMesh = $Puppet/PlayerModel/Armature/Skeleton/RightHand/Weapons.get_children()
	var skinMaterial = SpatialMaterial.new()
	skinMaterial.albedo_texture = load(skinPath)
	$Puppet/PlayerModel/Armature/Skeleton/Torso_Mesh.material_override = skinMaterial
	$Puppet/Nickname.text = nickname
	$Puppet/Nickname.modulate = Color(color)
	
	rset_config("transform_lerp", MultiplayerAPI.RPC_MODE_REMOTE)
	
	if is_network_master():
		get_tree().get_nodes_in_group("Multiplayer")[0].playerPuppet = self

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

func _process(delta):
	if $Puppet/PlayerModel/SFX/IED_alert.playing:
		$Puppet/PlayerModel/SFX/IED_alert.pitch_scale += 0.025

	global_transform = global_transform.interpolate_with(transform_lerp, delta * 15.0)

func _physics_process(delta):
	if is_network_master():
		rset_unreliable("transform_lerp", Global.player.global_transform)
		
		rpc("_update_puppet",
			Global.player.weapon.current_weapon,
			Global.player.dead,
			Global.player.is_on_floor(),
			[Global.player.cmd.forward_move,Global.player.cmd.right_move],
			Global.player.rotation_helper.rotation.x,
			Global.player.weapon.kickflag,
			Global.player.crouch_flag
		)
		hide()

func do_damage(damage, collision_n, collision_p, shooter_pos):
	rpc_id(int(self.name),"_do_damage", damage, collision_n, collision_p, shooter_pos, get_tree().get_network_unique_id())

func set_toxic():
	rpc_id(int(self.name),"_set_toxic")

func drop_weapon():
	rpc_id(int(self.name),"_drop_weapon")

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
