extends Node

onready var parent = get_parent()

func load_players():
	print("[LOCAL]: Load players")
	
	var puppetsNames = []
	for puppetNode in get_children():
		puppetsNames.append(int(puppetNode.name))
	
	for key in parent.players.keys():
		if not puppetsNames.has(key):
			var player = preload("res://MOD_CONTENT/CruS Online/multiplayer_player.tscn").instance()
			player.set_name(key)
			player.set_network_master(key)
			player.setup_puppet(key)
			player.nickname = parent.players[key].nickname
			player.skinPath = parent.players[key].skinPath
			player.color = parent.players[key].color
			player.singleton = parent
			add_child(player)
			parent.players[key]["puppet"] = player
			player.global_transform.origin = Vector3(-1000,-1000,-1000)
	print(parent.players)

func remove_players():
	for child in get_children():
		child.queue_free()
