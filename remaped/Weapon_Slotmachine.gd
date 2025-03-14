extends StaticBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var rotation_counter = - 1
var coin = preload("res://Entities/Physics_Objects/Coin.tscn")

var junk_items:Array = [
	preload("res://Entities/Physics_Objects/Chest_Gib.tscn"), 
	preload("res://Entities/Physics_Objects/Head_Gib.tscn"), 
	preload("res://Entities/Props/Plant_1.tscn"), 
	preload("res://Entities/Props/Trashcan.tscn"), 
	preload("res://Entities/Props/Monitor.tscn")
]

var weapon_drop = preload("res://Entities/Objects/Gun_Pickup.tscn")
var weapon_indexes:Array = [[0, 1, 4, 7, 9], [2, 5, 6, 8, 12, 13, 17], [18]]
var wep = 0

master func set_rotation_counter(id, recived_value):
	rotation_counter = recived_value

func _ready():
	NetworkBridge.register_rpcs(self, [
		["set_mech_rotation", NetworkBridge.PERMISSION.SERVER],
		["set_rotation_counter", NetworkBridge.PERMISSION.ALL],
		["notify", NetworkBridge.PERMISSION.SERVER],
		["play_audio", NetworkBridge.PERMISSION.SERVER],
		["client_spawn_item", NetworkBridge.PERMISSION.SERVER],
		["money_check", NetworkBridge.PERMISSION.SERVER],
		["check_use", NetworkBridge.PERMISSION.ALL]
	])

puppet func set_mech_rotation(id, value):
	$MeshInstance2.rotation.x = value

puppet func notify(id, value, color):
	Global.player.UI.notify(value, color)

puppet func play_audio(id):
	$Audio.play()

func _physics_process(delta):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		if rotation_counter >= 0:
			rotation_counter -= 1
			if not $Audio.playing:
				$Audio.play()
				NetworkBridge.n_rpc(self, "play_audio")
			$MeshInstance2.rotation.x += 1
			NetworkBridge.n_rpc_unreliable(self, "set_mech_rotation", [$MeshInstance2.rotation.x])
		if rotation_counter == 0:
			randomize()
			if randi() % 500 == 5:
				spawn_item()
				wep = 2
			elif randi() % 10 == 1:
				spawn_item()
				wep = 1
			elif randi() % 2 == 1:
				spawn_item()
				wep = 0
			else :
				Global.player.UI.notify("You lose", Color(1, 0, 0))
				NetworkBridge.n_rpc(self, "notify", ["You lose", Color(1, 0, 0)])
	else:
		set_physics_process(false)

func spawn_item():
	var new_weapon_drop = weapon_drop.instance()
	get_parent().add_child(new_weapon_drop)
	new_weapon_drop.gun.MESH[new_weapon_drop.gun.current_weapon].hide()
	var wepRand = randi() % weapon_indexes[wep].size()
	new_weapon_drop.set_name(new_weapon_drop.name + "#" + str(new_weapon_drop.get_instance_id()))
	new_weapon_drop.gun.current_weapon = weapon_indexes[wep][wepRand]
	new_weapon_drop.gun.ammo = Global.player.weapon.MAX_MAG_AMMO[new_weapon_drop.gun.current_weapon]
	new_weapon_drop.gun.MESH[new_weapon_drop.gun.current_weapon].show()
	new_weapon_drop.global_transform.origin = $Position3D.global_transform.origin
	new_weapon_drop.damage(5, (global_transform.origin - ($Forward_Position.global_transform.origin + Vector3(rand_range( - 0.1, 0.1), rand_range( - 0.1, 0.1), rand_range( - 0.1, 0.1)))).normalized(), global_transform.origin, Vector3.ZERO)
	
	new_weapon_drop.register_all_rpcs()
	new_weapon_drop.gun.register_all_rpcs()
	
	NetworkBridge.n_rpc(self, "client_spawn_item", [get_parent().get_path(), new_weapon_drop.name, new_weapon_drop.global_transform, wep, wepRand])

puppet func client_spawn_item(id, recivedPath, recivedName, recivedTransform, recivedIndexA, recivedIndexB):
	var new_weapon_drop = weapon_drop.instance()
	get_node(recivedPath).add_child(new_weapon_drop)
	new_weapon_drop.set_name(recivedName)
	new_weapon_drop.gun.MESH[new_weapon_drop.gun.current_weapon].hide()
	new_weapon_drop.gun.current_weapon = weapon_indexes[recivedIndexA][recivedIndexB]
	new_weapon_drop.gun.ammo = Global.player.weapon.MAX_MAG_AMMO[new_weapon_drop.gun.current_weapon]
	new_weapon_drop.gun.MESH[new_weapon_drop.gun.current_weapon].show()
	new_weapon_drop.global_transform = recivedTransform
	
	new_weapon_drop.register_all_rpcs()
	new_weapon_drop.gun.register_all_rpcs()

func player_use():
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		check_use(null, true)
	else:
		NetworkBridge.n_rpc(self, "check_use")

master func check_use(id, host = false):
	if rotation_counter >= 0:
		return
	
	if host:
		money_check(null)
	else:
		NetworkBridge.n_rpc(self, "money_check")

puppet func money_check(id):
	if Global.money < 10:
		Global.player.UI.notify("$10 required to play", Color(1, 1, 1))
		return 
	Global.money -= 10
	
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		rotation_counter = 50
	else:
		NetworkBridge.n_rpc(self, "set_rotation_counter", [50])
