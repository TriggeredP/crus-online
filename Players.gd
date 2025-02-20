extends Node

onready var parent = get_parent()

func load_players():
	print("[CRUS ONLINE / PLAYERS]: Load players")
	
	reload_players()
	
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
			player.transform_lerp.origin = Vector3(-1000,-1000,-1000)

func reload_players():
	print("[CRUS ONLINE / PLAYERS]: Reload players")
	for player in get_children():
		player.player_restart()

func remove_players():
	print("[CRUS ONLINE / PLAYERS]: Remove players")
	for player in get_children():
		player.queue_free()

func sync_players():
	print("[CRUS ONLINE / PLAYERS]: Sync players")
	print(get_children())
	
	for player in get_children():
		if parent.players[player.name] == null:
			player.queue_free()
