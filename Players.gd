extends Node

onready var parent = get_parent()

func load_players():
	print("[LOCAL]: Load players")
	
	var puppetsNames = []
	for puppetNode in get_children():
		puppetsNames.append(int(puppetNode.name))
	
	for key in parent.player_info.keys():
		if not puppetsNames.has(key):
			var player = preload("res://MOD_CONTENT/CruS Online/multiplayer_player.tscn").instance()
			player.set_name(key)
			player.set_network_master(key)
			player.nickname = parent.player_info[key].nickname
			player.skinPath = parent.player_info[key].skinPath
			player.color = parent.player_info[key].color
			player.singleton = parent
			add_child(player)
			parent.player_info[key]["puppet"] = player
			player.global_transform.origin = Vector3(0,-1000,0)
	print(parent.player_info)
