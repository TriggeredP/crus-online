extends Node

var version = "Alpha 060724/1839"

var player_info = {}

enum errorType {UNKNOW, TIME_OUT, WRONG_PASSWORD, WRONG_VERSION, PASSWORD_REQUIRE}

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

var lastConnected = {
	"ip": "127.0.0.1",
	"port": "25567"
}

var password = ""
var serverPassword = ""

var passwordEntered = false

var dataLoaded = false

onready var Players = $Players
onready var Menu = $Menu
onready var Hint = $Hint

var playerPuppet = null

signal status_update(status)
signal players_update(data)

signal connected_to_server()
signal disconnected_from_server(error)

#signal host_tick
#
#var is_ticking = false
#var tick = 0
#
#func _physics_process(delta):
#	if is_ticking and tick % 2 == 0:
#		print("host tick")
#		emit_signal("host_tick")
#		tick = 0
#	tick += 1

func _ready():
	if not load_data():
		save_data()
	
	get_tree().get_nodes_in_group("MultiplayerMenu")[0].data_init()

	get_tree().connect("network_peer_connected", self, "_connected")
	get_tree().connect("network_peer_disconnected", self, "_disconnected")

func clear_connection(recivedError):
	emit_signal("disconnected_from_server", recivedError)
	print("[CRUS ONLINE]: ERROR " + str(recivedError))
	
	get_tree().network_peer = null

func host_server(port, recivedHostSettings = null):
	save_data()
	
	if recivedHostSettings != null:
		hostSettings = recivedHostSettings
	var server = NetworkedMultiplayerENet.new()
	server.create_server(port,16)
	get_tree().set_network_peer(server)
	
	print(hostSettings)
	
	player_info[1] = my_info
	
	emit_signal("players_update", player_info)
	emit_signal("status_update", "Hosting server")
	
	dataLoaded = true
	print("Server hosted")

func join_to_server(ip,port):
	save_data()
	
	lastConnected.ip = ip
	lastConnected.port = port
	
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ip,port)
	get_tree().set_network_peer(client)
	
	print("Client try to connect")

func _disconnected(id):
	if player_info[id] != null:
		player_info.erase(id)
		emit_signal("players_update", player_info)
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
		rpc("password_require_check", passwordEntered)
		print("[CLIENT]: Connect Init")

puppet func disconnect_client(recivedError):
	clear_connection(recivedError)
	
	passwordEntered = false
	password = ""

master func password_require_check(recivedPasswordEntered):
	var id = get_tree().get_rpc_sender_id()
	
	if recivedPasswordEntered:
		rpc_id(id, "password_checked")
	else:
		if serverPassword != "":
			rpc_id(id, "disconnect_client", errorType.PASSWORD_REQUIRE)
		else:
			rpc_id(id, "password_not_require")

puppet func password_not_require():
		password = ""
		rpc("connect_init", password, version)

puppet func password_checked():
	rpc("connect_init", password, version)

master func connect_init(recivedPassword, recivedVersion):
	var id = get_tree().get_rpc_sender_id()
	
	if recivedVersion != version:
		rpc_id(id, "disconnect_client", errorType.WRONG_VERSION)
	else:
		if recivedPassword == serverPassword:
			rpc_id(id, "client_connect_init", hostSettings, player_info, Global.CURRENT_LEVEL)
			print("[HOST]: Client Connect Init")
		else:
			rpc_id(id, "disconnect_client", errorType.WRONG_PASSWORD)

puppet func client_connect_init(recivedHostSettings,recivedPlayerInfo, level):
	hostSettings = recivedHostSettings
	player_info = recivedPlayerInfo
	
	passwordEntered = false
	password = ""
	
	dataLoaded = true
	rpc("host_add_player", my_info)

	emit_signal("status_update", "Connected to server")
	emit_signal("connected_to_server")
	
	print("[CLIENT]: Player connected")

remote func connect_notify(nickname):
	Global.UI.notify(nickname + " connected", Color(1, 0, 0))

master func host_add_player(info):
	var id = get_tree().get_rpc_sender_id()
	
	if player_info[id] == null:
		player_info[id] = info
		rpc("sync_players",player_info)
		print("[HOST]: Sync player info")
		
		emit_signal("players_update", player_info)

master func host_remove_player():
	var id = get_tree().get_rpc_sender_id()

	if player_info[id] != null:
		player_info.erase(id)
		rpc("sync_players",player_info)

puppet func sync_players(info):
	player_info = info
	emit_signal("players_update", player_info)
	print("[CLIENT]: Player info synced")

################################################################################

func goto_menu_host():
	Global.menu.multiplayer_exit()
	get_tree().network_peer.refuse_new_connections = false
	Global.CURRENT_LEVEL = 0
	Global.goto_scene("res://MOD_CONTENT/CruS Online/maps/crus_online_lobby.tscn")
	rpc("goto_menu_client")
	print("[HOST]: Goto to menu")
	
	Players.remove_players()

puppet func goto_menu_client():
	Global.menu.multiplayer_exit()
	Global.CURRENT_LEVEL = 0
	Global.goto_scene("res://MOD_CONTENT/CruS Online/maps/crus_online_lobby.tscn")
	print("[CLIENT]: Goto to menu")
	
	Players.remove_players()

################################################################################

func goto_scene_host(scene):
	disable_menu()
	get_tree().network_peer.refuse_new_connections = true
	Global.goto_scene(scene)
	rpc("goto_scene_client", scene, Global.CURRENT_LEVEL)
	print("[HOST]: Goto to scene [" + scene + "]")
	
	Players.load_players()

puppet func goto_scene_client(scene, level):
	disable_menu()
	Global.CURRENT_LEVEL = level
	Global.goto_scene(scene)
	print("[CLIENT]: Goto to scene [" + scene + "]")
	
	Players.load_players()

################################################################################

func enable_menu():
	Global.menu.multiplayer_exit()
	Global.menu.set_process_input(true)
	Menu.set_process_input(false)

func disable_menu():
	Global.menu.multiplayer_enter()
	Global.menu.set_process_input(false)
	Menu.set_process_input(true)

################################################################################

func game_init(level) -> bool:
	if get_tree().network_peer == null:
		host_server(25567)
	
	if get_tree().is_network_server():
		goto_scene_host(level)
		return true
	return false

################################################################################

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
