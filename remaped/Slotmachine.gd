extends StaticBody

var rotation_counter = - 1
var coin = preload("res://Entities/Physics_Objects/Coin.tscn")

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
			if randi() % 1000 == 500:
				Global.player.UI.notify("You win $1000!", Color(1, 0, 1))
				spawn_coins(100)
			elif randi() % 10 == 1:
				Global.player.UI.notify("You win $100!", Color(0, 1, 0))
				spawn_coins(10)
			elif randi() % 2 == 1:
				Global.player.UI.notify("You win $10!", Color(0, 1, 0))
				spawn_coins(1)
			else :
				Global.player.UI.notify("You lose", Color(1, 0, 0))
	else:
		set_physics_process(false)

func spawn_coins(amount):
	for i in range(amount):
		var new_coin = coin.instance()
		add_child(new_coin)
		new_coin.global_transform.origin = $Position3D.global_transform.origin
		new_coin.damage(20, (global_transform.origin - ($Forward_Position.global_transform.origin + Vector3(rand_range( - 0.1, 0.1), rand_range( - 0.1, 0.1), rand_range( - 0.1, 0.1)))).normalized(), global_transform.origin, Vector3.ZERO)
		yield (get_tree(), "idle_frame")
		yield (get_tree(), "idle_frame")

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
