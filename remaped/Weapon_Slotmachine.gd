extends StaticBody

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

func _ready():
	rset_config("rotation_counter", MultiplayerAPI.RPC_MODE_MASTER)
	$MeshInstance2.rset_config("rotation/x", MultiplayerAPI.RPC_MODE_PUPPET)

puppet func play_audio():
	$Audio.play()

func _physics_process(delta):
	if is_network_master():
		if rotation_counter >= 0:
			rotation_counter -= 1
			if not $Audio.playing:
				$Audio.play()
				rpc("play_audio")
			$MeshInstance2.rotation.x += 1
			$MeshInstance2.rset_unreliable("rotation/x", $MeshInstance2.rotation.x)
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
	else:
		set_physics_process(false)

func spawn_item():
	var new_weapon_drop = weapon_drop.instance()
	get_parent().add_child(new_weapon_drop)
	new_weapon_drop.gun.MESH[new_weapon_drop.gun.current_weapon].hide()
	new_weapon_drop.gun.current_weapon = weapon_indexes[wep][randi() % weapon_indexes[wep].size()]
	new_weapon_drop.gun.ammo = Global.player.weapon.MAX_MAG_AMMO[new_weapon_drop.gun.current_weapon]
	new_weapon_drop.gun.MESH[new_weapon_drop.gun.current_weapon].show()
	new_weapon_drop.global_transform.origin = $Position3D.global_transform.origin
	new_weapon_drop.damage(5, (global_transform.origin - ($Forward_Position.global_transform.origin + Vector3(rand_range( - 0.1, 0.1), rand_range( - 0.1, 0.1), rand_range( - 0.1, 0.1)))).normalized(), global_transform.origin, Vector3.ZERO)

func player_use():
	if is_network_master():
		check_use()
	else:
		rpc("check_use")

master func check_use():
	if rotation_counter >= 0:
		return
	
	if is_network_master():
		money_check()
	else:
		rpc("money_check")

puppet func money_check():
	if Global.money < 10:
		Global.player.UI.notify("$10 required to play", Color(1, 1, 1))
		return 
	Global.money -= 10
	
	if is_network_master():
		rotation_counter = 50
	else:
		rset("rotation_counter", 50)
