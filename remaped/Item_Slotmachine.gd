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

func _ready():
	rset_config("rotation_counter", MultiplayerAPI.RPC_MODE_MASTER)

puppet func set_mech_rotation(value):
	$MeshInstance2.rotation.x = value

puppet func notify(value, color):
	Global.player.UI.notify(value, color)

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
			rpc_unreliable("set_mech_rotation", $MeshInstance2.rotation.x)
		if rotation_counter == 0:
			randomize()
			if randi() % 1000 == 500:
				spawn_item()
			elif randi() % 10 == 1:
				spawn_item()
			elif randi() % 2 == 1:
				spawn_item()
			else :
				Global.player.UI.notify("You lose", Color(1, 0, 0))
				rpc("notify", "You lose", Color(1, 0, 0))
	else:
		set_physics_process(false)

func spawn_item():
	var selectedItem = randi() % junk_items.size()
	var new_coin = junk_items[selectedItem].instance()
	new_coin.set_name(new_coin.name + "#" + str(randi() % 100000000))
	add_child(new_coin)
	new_coin.global_transform.origin = $Position3D.global_transform.origin
	new_coin.damage(20, (global_transform.origin - ($Forward_Position.global_transform.origin + Vector3(rand_range( - 0.1, 0.1), rand_range( - 0.1, 0.1), rand_range( - 0.1, 0.1)))).normalized(), global_transform.origin, Vector3.ZERO)
	rpc("client_spawn_item", selectedItem, get_path(), new_coin.name, new_coin.global_transform)

puppet func client_spawn_item(recivedItem, recivedPath, recivedName, recivedTransform):
	var new_coin = junk_items[recivedItem].instance()
	new_coin.set_name(recivedName)
	get_node(recivedPath).add_child(new_coin)
	new_coin.global_transform = recivedTransform

func player_use():
	if is_network_master():
		check_use(true)
	else:
		rpc("check_use")

master func check_use(host = false):
	if rotation_counter >= 0:
		return
	
	if host:
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
