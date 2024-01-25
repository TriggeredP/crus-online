extends Node

export var playerId:int = 0

var player_info = {}

var my_info = {}

var hostSettings = {}

var dataLoaded = false

onready var Sync = $Sync
onready var Players = $Players
onready var Menu = $Menu
onready var Hint = $Hint

func _ready():
	get_tree().connect("network_peer_connected", self, "_connected")
	get_tree().connect("network_peer_disconnected", self, "_disconnected")

func host_server(port,info,recivedHostSettings): 
	my_info = info
	hostSettings = recivedHostSettings
	var server = NetworkedMultiplayerENet.new()
	server.create_server(port,16)
	get_tree().set_network_peer(server)
	playerId = 1
	
	print(hostSettings)
	
	player_info[1] = my_info
	
	Global.menu.hide()
	Global.menu.set_process_input(false)
	Global.goto_scene(hostSettings.map)
	Menu.set_process_input(true)
	
	dataLoaded = true
	print("Server hosted")

func join_to_server(ip,port,info):
	my_info = info
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ip,port)
	get_tree().set_network_peer(client)
	playerId = get_tree().get_network_unique_id()
	
	print("Client try to connect")

func _disconnected(id):
	if player_info[id] != null:
		Players.get_node(str(id)).queue_free()
		Global.UI.notify(player_info[id].nickname + " disconnected", Color(1, 0, 0))
		player_info.erase(id)
		print("Disconnected")

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
	
	Global.menu.hide()
	Global.menu.set_process_input(false)
	Global.goto_scene(hostSettings.map)
	Menu.set_process_input(true)
	
	dataLoaded = true
	rpc("host_add_player", my_info)
	rpc("connect_notify",my_info.nickname)
	print("[CLIENT]: Player connected")

remote func connect_notify(nickname):
	Global.UI.notify(nickname + " connected", Color(1, 0, 0))

master func host_add_player(info):
	var id = get_tree().get_rpc_sender_id()
	
	if player_info[id] == null:
		player_info[id] = info
		rpc("sync_players",player_info)
		print("[HOST]: Sync player info")
		Sync.sync_nodes()
		Players.load_players()

master func host_remove_player():
	var id = get_tree().get_rpc_sender_id()

	if player_info[id] != null:
		player_info.erase(id)
		rpc("sync_players",player_info)

puppet func sync_players(info):
	player_info = info
	Players.load_players()

