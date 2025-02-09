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

func _ready():
	rset_config("rotation_counter", MultiplayerAPI.RPC_MODE_MASTER)

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
			if randi() % 1000 == 500:
				spawn_item()
			elif randi() % 10 == 1:
				spawn_item()
			elif randi() % 2 == 1:
				spawn_item()
			else :
				Global.player.UI.notify("You lose", Color(1, 0, 0))
				NetworkBridge.n_rpc(self, "notify", ["You lose", Color(1, 0, 0)])
	else:
		set_physics_process(false)

func spawn_item():
	var selectedItem = randi() % junk_items.size()
	var new_coin = junk_items[selectedItem].instance()
	new_coin.set_name(new_coin.name + "#" + str(new_coin.get_instance_id()))
	add_child(new_coin)
	new_coin.global_transform.origin = $Position3D.global_transform.origin
	new_coin.damage(20, (global_transform.origin - ($Forward_Position.global_transform.origin + Vector3(rand_range( - 0.1, 0.1), rand_range( - 0.1, 0.1), rand_range( - 0.1, 0.1)))).normalized(), global_transform.origin, Vector3.ZERO)
	NetworkBridge.n_rpc(self, "client_spawn_item", [selectedItem, get_path(), new_coin.name, new_coin.global_transform])

puppet func client_spawn_item(id, recivedItem, recivedPath, recivedName, recivedTransform):
	var new_coin = junk_items[recivedItem].instance()
	new_coin.set_name(recivedName)
	get_node(recivedPath).add_child(new_coin)
	new_coin.global_transform = recivedTransform

func player_use():
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		check_use(true)
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
		NetworkBridge.n_rset(self, "rotation_counter", 50)
