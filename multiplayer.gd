extends Node

enum players_type {HOST,CLIENT}

export (players_type) var type
export var playerId:int = 0

var player_info = {}

var my_info = {name:"gay"}

var hostSettings = {}

var dataLoaded = false

func _ready():
	get_tree().connect("network_peer_connected", self, "_connected")
	get_tree().connect("network_peer_disconnected", self, "_disconnected")
	
	var thread = Thread.new()
	thread.start(self, "_upnp_setup", 6969)

func _upnp_setup(server_port):
	var upnp = UPNP.new()
	var err = upnp.discover()
	
	print(err)

	if err != OK:
		push_error(str(err))
		print("UPNP error")

	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "TCP")
		print("UPNP completed")

func host_server(port,info,recivedHostSettings): 
	my_info = info
	hostSettings = recivedHostSettings
	var server = NetworkedMultiplayerENet.new()
	server.create_server(port,16)
	get_tree().set_network_peer(server)
	type = players_type.HOST
	playerId = 1
	
	print(hostSettings)
	
	player_info[1] = my_info
	
	Global.goto_scene("res://MOD_CONTENT/CruS Online/maps/" + hostSettings.map)
	dataLoaded = true
	
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

remote func disconnect_player(id):
	get_node("Players/" + str(id)).queue_free()
	player_info.erase(id)

################################################################################

# ALL: 			_connected
# HOST: 		connected_init
# CLIENT: 		client_connected_init
# HOST: 		host_add_player 			-> 		load_players
# CLIENTS: 		sync_players 				-> 		load_players

################################################################################

func _connected(id):
	if not dataLoaded:
		rpc("connect_init")
		print("[CLIENT]: Connect Init")

master func connect_init():
	var id = get_tree().get_rpc_sender_id()
	rpc_id(id,"client_connect_init",hostSettings,player_info)
	print("[HOST]: Client Connect Init")

puppet func client_connect_init(recivedHostSettings,recivedPlayerInfo):
	hostSettings = recivedHostSettings
	player_info = recivedPlayerInfo
	Global.goto_scene("res://MOD_CONTENT/CruS Online/maps/" + hostSettings.map)
	dataLoaded = true
	rpc("host_add_player", my_info)
	print("[CLIENT]: Player connected")

master func host_add_player(info):
	var id = get_tree().get_rpc_sender_id()
	
	if player_info[id] == null:
		player_info[id] = info
		rpc("sync_players",player_info)
		print("[HOST]: Sync player info")
		load_players()

master func host_remove_player():
	var id = get_tree().get_rpc_sender_id()

	if player_info[id] != null:
		player_info.erase(id)
		rpc("sync_players",player_info)

puppet func sync_players(info):
	player_info = info
	load_players()

func load_players():
	print("[LOCAL]: Load players")
	
	var puppetsNames = []
	for puppetNode in get_node("Players").get_children():
		puppetsNames.append(int(puppetNode.name))
	
	for key in player_info.keys():
		if not puppetsNames.has(key):
			var player = preload("res://MOD_CONTENT/CruS Online/multiplayer_player.tscn").instance()
			player.set_name(key)
			player.set_network_master(key)
			player.nickname = player_info[key]["nickname"]
			player.skinPath = player_info[key]["skinPath"]
			player.singleton = self
			get_node("Players").add_child(player)
			player_info[key]["puppet"] = player
			player.global_transform.origin = Vector3(0,0,0)
	print(player_info)
