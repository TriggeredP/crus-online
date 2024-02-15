extends Node

export var playerId:int = 0

var player_info = {}

enum {PRIVATE,LAN,PUNCH_THROUTH}

var my_info = {
	"nickname": "MT Foxtrot",
	"color": "ff00ff",
	"image": "null",
	"skinPath": "res://Textures/Misc/mainguy_clothes.png"
}

var hostSettings = {
	"gamemode": "Cruelty",
	"map": "res://Levels/Level1.tscn",
	"bannedImplants": []
}

var dataLoaded = false

onready var Steam = $Steam

onready var HolePuncher = $HolePuncher

onready var Sync = $Sync
onready var Players = $Players
onready var Menu = $Menu
onready var Hint = $Hint

func _ready():
	if not load_data():
		save_data()

	HolePuncher.connect("holepunch_success", self, "_on_holepunch_success")
	HolePuncher.connect("holepunch_progress_update", self, "_on_holepunch_progress_update")
	HolePuncher.connect("holepunch_failure", self, "_on_holepunch_failure")


	get_tree().connect("network_peer_connected", self, "_connected")
	get_tree().connect("network_peer_disconnected", self, "_disconnected")

func _on_holepunch_success(self_port, host_ip, host_port):
	print(self_port, host_ip, host_port)

func _on_holepunch_progress_update(type, session_name, player_names):
	if HolePuncher.is_host():
		HolePuncher.start_session()
	print(type, session_name, player_names)

func _on_holepunch_failure(error):
	print(error)

func host_server_pt():
	var code = str(int(rand_range(0,1000000000)))
	print(code)
	
	HolePuncher.create_session(code, "host", 2, "12345")

func join_to_server_pt(gameCode):
	HolePuncher.join_session(gameCode, "client", 2, "12345")

func host_server(port, recivedHostSettings = null):
	save_data()
	
	if recivedHostSettings != null:
		hostSettings = recivedHostSettings
	var server = NetworkedMultiplayerENet.new()
	server.create_server(port,16)
	get_tree().set_network_peer(server)
	playerId = 1
	
	print(hostSettings)
	
	player_info[1] = my_info
	
	Global.menu.hide()
	Global.menu.set_process_input(false)
	goto_scene_host(hostSettings.map)
	Menu.set_process_input(true)
	
	dataLoaded = true
	print("Server hosted")

func join_to_server(ip,port):
	save_data()
	
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
	rpc_id(id,"client_connect_init", hostSettings, player_info, Global.CURRENT_LEVEL)
	print("[HOST]: Client Connect Init")

puppet func client_connect_init(recivedHostSettings,recivedPlayerInfo, level):
	hostSettings = recivedHostSettings
	player_info = recivedPlayerInfo
	
	Global.menu.hide()
	Global.menu.set_process_input(false)
	goto_scene_client(hostSettings.map, level)
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

func goto_scene_host(scene):
	Global.goto_scene(scene)
	rpc("goto_scene_client", scene, Global.CURRENT_LEVEL)
	print("[HOST]: goto to scene [" + scene + "]")

puppet func goto_scene_client(scene, level):
	Global.CURRENT_LEVEL = level
	Global.goto_scene(scene)
	print("[CLIENT]: goto to scene [" + scene + "]")

func save_data():
	var dir = Directory.new()
	if not dir.dir_exists("user://mod_config/"):
		dir.make_dir("user://mod_config/")
	
	var mod_config = File.new()
	mod_config.open("user://mod_config/CruSOnline.save", File.WRITE)
	mod_config.store_line(to_json(my_info))
	mod_config.close()
	
	print("[CruS Online]: Saved")

func load_data() -> bool:
	var dir = Directory.new()
	if not dir.dir_exists("user://mod_config/"):
		dir.make_dir("user://mod_config/")

	var file = File.new()
	if file.file_exists("user://mod_config/CruSOnline.save"):
		file.open("user://mod_config/CruSOnline.save", File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			my_info = data
			
			print("[CruS Online]: Loaded")
			return true
		else:
			printerr("[CruS Online]: Corrupted data!")
			return false
	else:
		printerr("[CruS Online]: No saved data!")
		return false
