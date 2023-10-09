extends Node

enum players_type {HOST,CLIENT}

export (players_type) var type
export var playerId:int = 0

var player_info = {}

var my_info = {name:"gay"}

var loaded = false

func _ready():
	get_tree().connect("network_peer_connected", self, "_connected")
	get_tree().connect("network_peer_disconnected", self, "_disconnected")

func host_server(port,info): 
	my_info = info
	var server = NetworkedMultiplayerENet.new()
	server.create_server(port,16)
	get_tree().set_network_peer(server)
	type = players_type.HOST
	playerId = 1
	
	if not loaded:
		Global.goto_scene("res://MOD_CONTENT/CruS Online/maps/multiplayer_test_map.tscn")
		loaded = true
	
	print("Server hosted")

func join_to_server(ip,port,info):
	my_info = info
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ip,port)
	get_tree().set_network_peer(client)
	type = players_type.CLIENT
	playerId = get_tree().get_network_unique_id()
	
	print("Client try to connect")

func _disconnected(id):
	if player_info[id] != null:
		rpc("disconnect_player",id)
		print("Disconnected")

func _connected(id):
	if not loaded:
		Global.goto_scene("res://MOD_CONTENT/CruS Online/maps/multiplayer_test_map.tscn")
		loaded = true
	if player_info[id] == null:
		print("My id ",playerId)
		rpc_id(id, "register_player", my_info)
		print("Player connected")

remote func disconnect_player(id):
	if Global.player.health != null:
		Global.player.UI.notify(player_info[id]["nickname"] + " disconnected", Color(1, 0, 0))
	
	get_node("Players/" + str(id)).queue_free()
	player_info.erase(id)

remote func register_player(info):
	var id = get_tree().get_rpc_sender_id()
	print("Get id ",id)
	
	player_info[id] = info
	
	if Global.player.health != null:
		Global.player.UI.notify(info["nickname"] + " entered the game", Color(1, 0, 0))
	
	var players = player_info
	players[playerId] = my_info
	
	var puppetsNames = []
	
	for puppetNode in get_node("Players").get_children():
		puppetsNames.append(int(puppetNode.name))
	
	for key in players.keys():
		if not puppetsNames.has(key):
			var player = preload("res://MOD_CONTENT/CruS Online/multiplayer_player.tscn").instance()
			player.set_name(key)
			player.set_network_master(key)
			player.nickname = player_info[key]["nickname"]
			player.skinPath = player_info[key]["skinPath"]
			player.singleton = self
			get_node("Players").add_child(player)
			player_info[key]["puppet"] = player
			player.global_transform.origin = Vector3(-100,-100,-100)
	
	print(player_info)
