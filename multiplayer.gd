extends Node

var version = "Alpha 150824/1725"

enum errorType {UNKNOW, TIME_OUT, WRONG_PASSWORD, WRONG_VERSION, PASSWORD_REQUIRE}

var playerInfo = {
	"nickname": "MT Foxtrot",
	"color": "ff00ff",
	"image": "null",
	"skinPath": "res://Textures/Misc/mainguy_clothes.png"
}

var hostSettings = {
	"bannedImplants" : [],
	"map" : null,
	"helpTimer": 15,
	"canRespawn": false,
	"changeModeOnDeath": true
}

var config = {
	"lastIp": "127.0.0.1",
	"lastPort": 25567,
	"hostPort": 25567,
	"hostPassword": "",
	"tickRate": 3,
	"helpTimer": 15,
	"canRespawn": false,
	"changeModeOnDeath": true
}

var password = ""

var passwordEntered = false

var dataLoaded = false

var players = {}

var playerPuppet = null

onready var DeathScreen = Global.get_node('DeathScreen')

onready var Players = $Players
onready var Menu = $Menu
onready var Hint = $Hint

signal status_update(status)
signal players_update(data)

signal host_tick()

signal connected_to_server()
signal disconnected_from_server(error)

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	get_tree().get_nodes_in_group("MultiplayerMenu")[0].data_init()

	get_tree().connect("network_peer_connected", self, "_connected")
	get_tree().connect("network_peer_disconnected", self, "_disconnected")
	
	Global.connect("scene_loaded", self, "_scene_loaded")

var tick = 0

func _physics_process(delta):
	if get_tree().network_peer != null and is_network_master() and tick % config.tickRate == 0:
		emit_signal("host_tick")
		tick = 0
	tick += 1

func clear_connection(recivedError):
	emit_signal("disconnected_from_server", recivedError)
	print("[CRUS ONLINE]: ERROR " + str(recivedError))
	
	get_tree().network_peer = null

func host_server(port):
	hostSettings.helpTimer = config.helpTimer
	hostSettings.canRespawn = config.canRespawn
	hostSettings.changeModeOnDeath = config.changeModeOnDeath
	
	var server = NetworkedMultiplayerENet.new()
	server.create_server(port,16)
	get_tree().set_network_peer(server)

	players[1] = playerInfo
	
	emit_signal("players_update", players)
	emit_signal("status_update", "Hosting server")
	
	dataLoaded = true
	print("Server hosted")

func join_to_server(ip, port):
	config.lastIp = ip
	config.lastPort = port
	
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ip,port)
	get_tree().set_network_peer(client)
	
	print("Client try to connect")

func leave_server():
	get_tree().network_peer = null
	dataLoaded = false
	players = {}
	
	emit_signal("status_update", "Offline")
	emit_signal("players_update", players)
	
	print("Server leaved")

func _disconnected(id):
	var playerPuppet = get_node_or_null("Players/" + str(id))
	
	if playerPuppet != null:
		playerPuppet.queue_free()
	
	if players[id] != null:
		if Global.player.health != null:
			Global.UI.notify(players[id].nickname + " disconnected", Color(1, 0, 0))
		
		players.erase(id)
		emit_signal("players_update", players)
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
		if config.hostPassword != "":
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
		if recivedPassword == config.hostPassword:
			rpc_id(id, "client_connect_init", hostSettings, players, Global.CURRENT_LEVEL)
			print("[HOST]: Client Connect Init")
		else:
			rpc_id(id, "disconnect_client", errorType.WRONG_PASSWORD)

puppet func client_connect_init(recivedHostSettings, recivedPlayerInfo, level):
	players = recivedPlayerInfo
	hostSettings = recivedHostSettings
	
	passwordEntered = false
	password = ""
	
	dataLoaded = true
	rpc("host_add_player", playerInfo)

	emit_signal("status_update", "Connected to server")
	emit_signal("connected_to_server")
	
	print("[CLIENT]: Player connected")

remote func connect_notify(nickname):
	Global.UI.notify(nickname + " connected", Color(1, 0, 0))

master func host_add_player(info):
	var id = get_tree().get_rpc_sender_id()
	
	if players[id] == null:
		players[id] = info
		rpc("sync_players",players)
		print("[HOST]: Sync player info")
		
		emit_signal("players_update", players)

master func host_remove_player():
	var id = get_tree().get_rpc_sender_id()

	if players[id] != null:
		players.erase(id)
		rpc("sync_players",players)

puppet func sync_players(info):
	players = info
	emit_signal("players_update", players)
	print("[CLIENT]: Player info synced")

################################################################################

func goto_menu_host(levelFinished = false):
	var menuPath = "res://MOD_CONTENT/CruS Online/maps/crus_online_lobby.tscn"
	
	if levelFinished:
		menuPath = level_finished()
	
	get_tree().paused = false
	
	Global.cutscene = false
	Global.border.show()
	
	enable_menu()
	get_tree().network_peer.refuse_new_connections = false
	Global.CURRENT_LEVEL = 0
	Global.goto_scene(menuPath)
	rpc("goto_menu_client", levelFinished)
	print("[HOST]: Goto to menu")
	
	Players.remove_players()

puppet func goto_menu_client(levelFinished = false):
	var menuPath = "res://MOD_CONTENT/CruS Online/maps/crus_online_lobby.tscn"
	
	if levelFinished:
		menuPath = level_finished()
	
	get_tree().paused = false
	
	Global.cutscene = false
	Global.border.show()
	
	enable_menu()
	Global.CURRENT_LEVEL = 0
	Global.goto_scene(menuPath)
	print("[CLIENT]: Goto to menu")
	
	Players.remove_players()

func level_finished():
	if Global.player.weapon.weapon1 != null:
		if not Global.WEAPONS_UNLOCKED[Global.player.weapon.weapon1]:
			Global.WEAPONS_UNLOCKED[Global.player.weapon.weapon1] = true
	
	if Global.player.weapon.weapon2 != null:
		if not Global.WEAPONS_UNLOCKED[Global.player.weapon.weapon2]:
			Global.WEAPONS_UNLOCKED[Global.player.weapon.weapon2] = true
	
	if Global.CURRENT_LEVEL + 1 > Global.LEVELS_UNLOCKED and Global.CURRENT_LEVEL + 1 <= Global.L_PUNISHMENT:
		Global.LEVELS_UNLOCKED = Global.CURRENT_LEVEL + 1
		Global.LEVELS_UNLOCKED = clamp(Global.LEVELS_UNLOCKED, 1, 12)
	
	if Global.CURRENT_LEVEL == Global.L_PUNISHMENT:
		Global.ending_1 = true
		Global.water_material.set_shader_param("albedoTex", Global.red_water)
	
	if Global.punishment_mode:
		Global.money += Global.LEVEL_REWARDS[Global.CURRENT_LEVEL] * 2
	else :
		Global.money += Global.LEVEL_REWARDS[Global.CURRENT_LEVEL]
	if Global.punishment_mode:
		if not Global.LEVEL_PUNISHED[Global.CURRENT_LEVEL] and not Global.hope_discarded:
			Global.set_soul()
		Global.LEVEL_PUNISHED[Global.CURRENT_LEVEL] = true
	if Global.levels_completed() and Global.BONUS_UNLOCK.find("END") == - 1:
		Global.BONUS_UNLOCK.append("END")
	Global.save_game()
	
	if Global.CURRENT_LEVEL == Global.L_PUNISHMENT:
		return "res://Cutscenes/CutsceneEnd1.tscn"
	elif Global.CURRENT_LEVEL == Global.L_HQ:
		Global.ending_2 = true
		Global.save_game()
		Global.character_mat.set_shader_param("albedoTex", load("res://Textures/NPC/bosssguy_clothes.png"))
		return "res://Cutscenes/CutsceneEnd2.tscn"
	elif Global.CURRENT_LEVEL == 18:
		Global.ending_3 = true
		Global.save_game()
		return "res://Cutscenes/CutsceneEnd3.tscn"
	else:
		return "res://MOD_CONTENT/CruS Online/maps/crus_online_lobby.tscn"

################################################################################

signal scene_loaded()

var loaded_players = []
var player_scene_loaded = true

func goto_scene_host(scene):
	hostSettings.map = scene
	
	died_players = []
	loaded_players = []
	player_scene_loaded = false
	
	Global.cutscene = false
	Global.border.show()
	
	disable_menu()
	get_tree().network_peer.refuse_new_connections = true
	Global.goto_scene(scene)
	rpc("goto_scene_client", scene, Global.CURRENT_LEVEL)
	print("[HOST]: Goto to scene [" + scene + "]")
	
	Players.load_players()

puppet func goto_scene_client(scene, level):
	player_scene_loaded = false
	
	Global.cutscene = false
	Global.border.show()
	
	disable_menu()
	Global.CURRENT_LEVEL = level
	Global.goto_scene(scene)
	print("[CLIENT]: Goto to scene [" + scene + "]")
	
	Players.load_players()

func _scene_loaded():
	if not player_scene_loaded:
		$SyncLoad.rect_scale = Vector2(Global.resolution[0] / 1280 ,Global.resolution[1] / 720 )
		$SyncLoad.show()
		player_scene_loaded = true
		get_tree().paused = true
		
		if is_network_master():
			loaded_players.append(1)
			connect("host_tick", self, "check_players_load")
		else:
			rpc("load_check")

func check_players_load():
	var is_players_loaded = true

	for player in players:
		if not loaded_players.has(player):
			is_players_loaded = false
	
	if is_players_loaded:
		disconnect("host_tick", self, "check_players_load")
		
		print("[HOST]: Players loaded")
		
		get_tree().paused = false
		$SyncLoad.hide()
		emit_signal("scene_loaded")
		rpc("scene_loaded_signal")

master func load_check():
	loaded_players.append(get_tree().get_rpc_sender_id())

puppet func scene_loaded_signal():
	get_tree().paused = false
	$SyncLoad.hide()
	emit_signal("scene_loaded")

################################################################################

var died_players = []

func player_died():
	if is_network_master():
		_player_died(true)
	else:
		rpc("_player_died")

master func _player_died(host = false):
	if host:
		if not died_players.has(1):
			died_players.append(1)
	else:
		if not died_players.has(get_tree().get_rpc_sender_id()):
			died_players.append(get_tree().get_rpc_sender_id())
	
	var all_player_died = true

	for player in players:
		if not died_players.has(player):
			all_player_died = false
	
	if all_player_died:
		print("[HOST]: All players is dead lol")
		$RestartTimer.start()
		set_death_label()
		rpc("set_death_label")

puppet func set_death_label():
	DeathScreen.set_death_label()

func restart_map():
	hide_death_screen()
	rpc("hide_death_screen")
	goto_scene_host(hostSettings.map)

puppet func hide_death_screen():
	DeathScreen.hide()

func player_respawn():
	if is_network_master():
		_player_respawn(true)
	else:
		rpc("_player_respawn")

master func _player_respawn(host = false):
	if host:
		if died_players.has(1):
			died_players.erase(1)
	else:
		if not died_players.has(get_tree().get_rpc_sender_id()):
			died_players.erase(get_tree().get_rpc_sender_id())

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
		host_server(config.hostPort)
	
	if get_tree().is_network_server():
		goto_scene_host(level)
		return true
	return false
