extends StaticBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var rotation_counter = - 1
var coin = preload("res://Entities/Physics_Objects/Coin.tscn")

func _ready():
	NetworkBridge.register_rpcs(self, [
		["set_mech_rotation", NetworkBridge.PERMISSION.SERVER],
		["set_rotation_counter", NetworkBridge.PERMISSION.ALL],
		["notify", NetworkBridge.PERMISSION.SERVER],
		["play_audio", NetworkBridge.PERMISSION.SERVER],
		["client_spawn_coin", NetworkBridge.PERMISSION.SERVER],
		["money_check", NetworkBridge.PERMISSION.SERVER],
		["check_use", NetworkBridge.PERMISSION.ALL]
	])

master func set_rotation_counter(id, recived_value):
	rotation_counter = recived_value

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
				Global.player.UI.notify("You win $1000!", Color(1, 0, 1))
				NetworkBridge.n_rpc(self, "notify", ["You win $1000!", Color(1, 0, 1)])
				spawn_coins(100)
			elif randi() % 10 == 1:
				Global.player.UI.notify("You win $100!", Color(0, 1, 0))
				NetworkBridge.n_rpc(self, "notify", ["You win $100!", Color(0, 1, 0)])
				spawn_coins(10)
			elif randi() % 2 == 1:
				Global.player.UI.notify("You win $10!", Color(0, 1, 0))
				NetworkBridge.n_rpc(self, "notify", ["You win $10!", Color(0, 1, 0)])
				spawn_coins(1)
			else :
				Global.player.UI.notify("You lose", Color(1, 0, 0))
				NetworkBridge.n_rpc(self, "notify", ["You lose", Color(1, 0, 0)])
	else:
		set_physics_process(false)

func spawn_coins(amount):
	for i in range(amount):
		var new_coin = coin.instance()
		new_coin.set_name(new_coin.name + "#" + str(new_coin.get_instance_id()))
		add_child(new_coin)
		new_coin.fromSlotMachine = true
		new_coin.global_transform.origin = $Position3D.global_transform.origin
		new_coin.damage(20, (global_transform.origin - ($Forward_Position.global_transform.origin + Vector3(rand_range( - 0.1, 0.1), rand_range( - 0.1, 0.1), rand_range( - 0.1, 0.1)))).normalized(), global_transform.origin, Vector3.ZERO)
		NetworkBridge.n_rpc(self, "client_spawn_coin", [get_path(), new_coin.name, new_coin.global_transform])
		yield (get_tree(), "idle_frame")
		yield (get_tree(), "idle_frame")

puppet func client_spawn_coin(id, parentPath, recivedName, recivedTransform):
	var new_coin = coin.instance()
	new_coin.set_name(recivedName)
	new_coin.fromSlotMachine = true
	new_coin.global_transform = recivedTransform
	get_node(parentPath).add_child(new_coin)

func player_use():
	if NetworkBridge.check_connection():
		if NetworkBridge.n_is_network_master(self):
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
