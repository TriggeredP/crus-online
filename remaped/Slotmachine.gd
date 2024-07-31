extends StaticBody

var rotation_counter = - 1
var coin = preload("res://Entities/Physics_Objects/Coin.tscn")

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
				Global.player.UI.notify("You win $1000!", Color(1, 0, 1))
				rpc("notify", "You win $1000!", Color(1, 0, 1))
				spawn_coins(100)
			elif randi() % 10 == 1:
				Global.player.UI.notify("You win $100!", Color(0, 1, 0))
				rpc("notify", "You win $100!", Color(0, 1, 0))
				spawn_coins(10)
			elif randi() % 2 == 1:
				Global.player.UI.notify("You win $10!", Color(0, 1, 0))
				rpc("notify", "You win $10!", Color(0, 1, 0))
				spawn_coins(1)
			else :
				Global.player.UI.notify("You lose", Color(1, 0, 0))
				rpc("notify", "You lose", Color(1, 0, 0))
	else:
		set_physics_process(false)

func spawn_coins(amount):
	for i in range(amount):
		var new_coin = coin.instance()
		new_coin.set_name(new_coin.name + "#" + str(randi() % 100000000))
		add_child(new_coin)
		new_coin.fromSlotMachine = true
		new_coin.global_transform.origin = $Position3D.global_transform.origin
		new_coin.damage(20, (global_transform.origin - ($Forward_Position.global_transform.origin + Vector3(rand_range( - 0.1, 0.1), rand_range( - 0.1, 0.1), rand_range( - 0.1, 0.1)))).normalized(), global_transform.origin, Vector3.ZERO)
		rpc("client_spawn_coin", get_path(), new_coin.name, new_coin.global_transform)
		yield (get_tree(), "idle_frame")
		yield (get_tree(), "idle_frame")

puppet func client_spawn_coin(parentPath, recivedName, recivedTransform):
	var new_coin = coin.instance()
	new_coin.set_name(recivedName)
	new_coin.fromSlotMachine = true
	new_coin.global_transform = recivedTransform
	get_node(parentPath).add_child(new_coin)

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
