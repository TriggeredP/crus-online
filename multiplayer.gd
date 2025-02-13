extends Node

var version = "Beta 130225/2328"

enum errorType {UNKNOW, TIME_OUT, WRONG_PASSWORD, WRONG_VERSION, PASSWORD_REQUIRE, SERVER_CLOSED, UPNP_ERROR, PLAYER_CONNECTED}

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
onready var UDPLagger = $UDPLagger
onready var NetworkBridge = $NetworkBridge

onready var SteamInit = $SteamInit
onready var SteamLobby = $SteamInit/SteamLobby
onready var SteamNetwork = $SteamInit/SteamNetwork

signal status_update(status)
signal players_update(data)

signal host_tick()

signal connected_to_server()
signal disconnected_from_server(error)

signal throw_error(error)

# SERVER = PUPPET
# CLIENT_ALL = REMOTE

func _ready():
	SteamNetwork.register_rpcs(self,[
		["set_packages_count", SteamNetwork.PERMISSION.SERVER],
		["ping_set", SteamNetwork.PERMISSION.SERVER],
		["disconnect_client", SteamNetwork.PERMISSION.SERVER],
		["password_not_require", SteamNetwork.PERMISSION.SERVER],
		["password_checked", SteamNetwork.PERMISSION.SERVER],
		["client_connect_init", SteamNetwork.PERMISSION.SERVER],
		["sync_players", SteamNetwork.PERMISSION.SERVER],
		["goto_menu_client", SteamNetwork.PERMISSION.SERVER],
		["goto_scene_client", SteamNetwork.PERMISSION.SERVER],
		["scene_loaded_signal", SteamNetwork.PERMISSION.SERVER],
		["set_death_label", SteamNetwork.PERMISSION.SERVER],
		["hide_death_screen", SteamNetwork.PERMISSION.SERVER],
		["ping_host", SteamNetwork.PERMISSION.ALL],
		["password_require_check", SteamNetwork.PERMISSION.ALL],
		["connect_init", SteamNetwork.PERMISSION.ALL],
		["load_check", SteamNetwork.PERMISSION.ALL],
		["_player_died", SteamNetwork.PERMISSION.ALL],
		["_player_respawn", SteamNetwork.PERMISSION.ALL],
		["connected", SteamNetwork.PERMISSION.SERVER],
		["client_peer_connect", SteamNetwork.PERMISSION.SERVER]
	])
	
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	get_tree().get_nodes_in_group("MultiplayerMenu")[0].data_init()

	get_tree().connect("network_peer_connected", self, "connected")
	get_tree().connect("network_peer_disconnected", self, "disconnected")
	
	SteamNetwork.connect("all_peers_connected", self, "steam_peers_connect")
	
	Global.connect("scene_loaded", self, "_scene_loaded")

var tick = 0

var packages_count = 0

func _input(event):
	if event is InputEventKey and not event.echo and event.pressed:
		var key = event.scancode

		match key:
			KEY_F1:
				$Debug.visible = !$Debug.visible
			KEY_F2:
				print("[CRUS ONLINE / DEBUG] players: ")
				for player in players:
					print(str(player) + ": ", players[player])

func _physics_process(delta):
	if NetworkBridge.is_lan():
		if get_tree().network_peer != null and get_tree().network_peer.get_connection_status() == 0:
			goto_menu_client(null)
			clear_connection(errorType.SERVER_CLOSED)
		
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master() and tick % config.tickRate == 0:
		emit_signal("host_tick")
		tick = 0
	tick += 1

puppet func set_packages_count(id, value):
	$Debug/VBoxContainer/PPT.text = "Packages per sec: " + str(value)

func ping_check():
	if NetworkBridge.check_connection():
		if not NetworkBridge.n_is_network_master(self):
			NetworkBridge.n_rpc(self, "ping_host", [OS.get_ticks_msec()])
		else:
			$Debug/VBoxContainer/PPT.text = "Packages per sec: " + str(packages_count + 1)
			NetworkBridge.n_rpc(self, "set_packages_count", [packages_count])
			packages_count = 0

master func ping_host(id, recived_ping):
	NetworkBridge.n_rpc_id(self, id, "ping_set", [recived_ping])

puppet func ping_set(id, recived_ping):
	$Debug/VBoxContainer/Ping.text = "Ping: " + str(OS.get_ticks_msec() - recived_ping)

func clear_connection(recivedError):
	emit_signal("disconnected_from_server", recivedError)
	push_error("[CRUS ONLINE / MAIN]: ERROR " + str(recivedError))
	
	leave_server()

func host_server():
	if NetworkBridge.is_lan():
		hostSettings.helpTimer = config.helpTimer
		hostSettings.canRespawn = config.canRespawn
		hostSettings.changeModeOnDeath = config.changeModeOnDeath
		
		if UDPLagger.enabled:
			UDPLagger.setup()
		
		$Debug/VBoxContainer/Ping.text = "Ping: 0"
		$Debug/VBoxContainer/GameType.text = "Player is host"
		
		var server = NetworkedMultiplayerENet.new()
		server.create_server(config.hostPort, 16)
		get_tree().set_network_peer(server)

		players[1] = playerInfo
		
		emit_signal("players_update", players)
		emit_signal("status_update", "Hosting server")
		
		dataLoaded = true
		print("[CRUS ONLINE / MAIN]: Server hosted")

func join_to_server(ip, port):
	if NetworkBridge.is_lan():
		config.lastIp = ip
		config.lastPort = port
		
		$Debug/VBoxContainer/GameType.text = "Player is client"
		
		var client = NetworkedMultiplayerENet.new()
		client.create_client(ip,port)
		get_tree().set_network_peer(client)
		
		print("[CRUS ONLINE / MAIN]: Client try to connect")

func leave_server():
	dataLoaded = false
	players = {}
	
	$Debug/VBoxContainer/GameType.text = "Player is not connected"
	$Debug/VBoxContainer/PPT.text = "Packages per sec: 0"
	$Debug/VBoxContainer/Ping.text = "Ping: 0"
	
	emit_signal("status_update", "Offline")
	emit_signal("players_update", players)
	
	if NetworkBridge.is_lan():
		get_tree().network_peer = null
	else:
		SteamLobby.leave_lobby()
	
	print("[CRUS ONLINE / MAIN]: Server leaved")

################################################################################

# ALL: 			connected
# HOST: 		connected_init
# CLIENT: 		client_connected_init
# HOST: 		host_add_player 			-> 		load_players
# CLIENTS: 		sync_players 				-> 		load_players

################################################################################

func steam_peers_connect():
	emit_signal("status_update", "Lobby owner")
	
	playerInfo.nickname = SteamInit.steam_username
	players[NetworkBridge.get_host_id()] = playerInfo
	
	$Debug/VBoxContainer/GameType.text = "Player is host"
	NetworkBridge.n_rpc(self, "client_peer_connect")

puppet func client_peer_connect(id):
	emit_signal("status_update", "Connected to Lobby")
	$Debug/VBoxContainer/GameType.text = "Player is client"
	
	playerInfo.nickname = SteamInit.steam_username
	NetworkBridge.n_rpc(self, "connect_init", [password, version, playerInfo])

func disconnected(id):
	if NetworkBridge.is_lan():
		var playerPuppet = get_node_or_null("Players/" + str(id))
		
		if playerPuppet != null:
			playerPuppet.queue_free()
		
		if players[id] != null:
			if Global.player.health != null:
				Global.UI.notify(players[id].nickname + " disconnected", Color(1, 0, 0))
		
		players.erase(id)
		emit_signal("players_update", players)
		print("[CRUS ONLINE / MAIN]: Disconnected")

puppet func connected(id):
	if NetworkBridge.is_lan():
		if not dataLoaded:
			NetworkBridge.n_rpc(self, "password_require_check", [passwordEntered])
			print("[CRUS ONLINE / CLIENT]: Connect Init")

puppet func disconnect_client(id, recivedError):
	clear_connection(recivedError)
	
	passwordEntered = false
	password = ""

master func password_require_check(id, recivedPasswordEntered):
	if recivedPasswordEntered:
		NetworkBridge.n_rpc_id(self, id, "password_checked")
	else:
		if config.hostPassword != "":
			NetworkBridge.n_rpc_id(self, id, "disconnect_client", [errorType.PASSWORD_REQUIRE])
		else:
			NetworkBridge.n_rpc_id(self, id, "password_not_require")

puppet func password_not_require(id):
		password = ""
		NetworkBridge.n_rpc(self, "connect_init", [password, version, playerInfo])

puppet func password_checked(id):
	NetworkBridge.n_rpc(self, "connect_init", [password, version, playerInfo])

master func connect_init(id, recivedPassword, recivedVersion, recivedPlayerInfo):
	if recivedVersion != version:
		NetworkBridge.n_rpc_id(self, id, "disconnect_client", [errorType.WRONG_VERSION])
	else:
		if recivedPassword == config.hostPassword:
			NetworkBridge.n_rpc_id(self, id, "client_connect_init", [hostSettings, players])
			host_add_player(id, recivedPlayerInfo)
			emit_signal("throw_error", errorType.PLAYER_CONNECTED)
			print("[CRUS ONLINE / HOST]: Client Connect Init")
		else:
			NetworkBridge.n_rpc_id(self, id, "disconnect_client", [errorType.WRONG_PASSWORD])

puppet func client_connect_init(id, recivedHostSettings, recivedPlayerInfo):
	players = recivedPlayerInfo
	hostSettings = recivedHostSettings
	
	dataLoaded = true
	
	if NetworkBridge.is_lan():
		passwordEntered = false
		password = ""

		emit_signal("status_update", "Connected to server")
		emit_signal("connected_to_server")
		
		print("[CRUS ONLINE / CLIENT]: Player connected")

remote func connect_notify(id, nickname):
	Global.UI.notify(nickname + " connected", Color(1, 0, 0))

func host_add_player(id, info):
	if players[id] == null:
		players[id] = info
		NetworkBridge.n_rpc(self, "sync_players", [players])
		print("[CRUS ONLINE / HOST]: Sync player info")
		
		emit_signal("players_update", players)

master func host_remove_player(id):
	if players[id] != null:
		players.erase(id)
		NetworkBridge.n_rpc(self, "sync_players", [players])

puppet func sync_players(id, info):
	players = info
	emit_signal("players_update", players)
	print("[CRUS ONLINE / CLIENT]: Player info synced")

################################################################################

func goto_menu_host(levelFinished = false):
	$RestartTimer.stop()
	var menuPath = "res://MOD_CONTENT/CruS Online/maps/crus_online_lobby.tscn"
	
	DeathScreen.hide()
	
	if levelFinished:
		menuPath = level_finished()
	
	get_tree().paused = false
	
	Global.cutscene = false
	Global.border.show()
	
	enable_menu()
	
	if NetworkBridge.is_lan():
		get_tree().network_peer.refuse_new_connections = true
	else:
		SteamInit.Steam.setLobbyJoinable(SteamLobby.get_lobby_id(), false)
	
	Global.CURRENT_LEVEL = 0
	Global.goto_scene(menuPath)
	NetworkBridge.n_rpc(self, "goto_menu_client", [levelFinished])
	print("[CRUS ONLINE / HOST]: Goto to menu")
	
	Players.remove_players()

puppet func goto_menu_client(id, levelFinished = false):
	$RestartTimer.stop()
	var menuPath = "res://MOD_CONTENT/CruS Online/maps/crus_online_lobby.tscn"
	
	DeathScreen.hide()
	
	if levelFinished:
		menuPath = level_finished()
	
	get_tree().paused = false
	
	Global.cutscene = false
	Global.border.show()
	
	enable_menu()
	Global.CURRENT_LEVEL = 0
	Global.goto_scene(menuPath)
	print("[CRUS ONLINE / CLIENT]: Goto to menu")
	
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
	$RestartTimer.stop()
	hostSettings.map = scene
	
	died_players = []
	loaded_players = []
	player_scene_loaded = false
	
	Global.cutscene = false
	Global.border.show()
	
	disable_menu()
	
	if NetworkBridge.is_lan():
		get_tree().network_peer.refuse_new_connections = true
	else:
		SteamInit.Steam.setLobbyJoinable(SteamLobby.get_lobby_id(), false)
		
	Global.goto_scene(scene)
	NetworkBridge.n_rpc(self, "goto_scene_client", [scene, Global.CURRENT_LEVEL])
	print("[CRUS ONLINE / HOST]: Goto to scene [" + scene + "]")
	
	Players.load_players()

puppet func goto_scene_client(id, scene, level):
	$RestartTimer.stop()
	player_scene_loaded = false
	
	Global.cutscene = false
	Global.border.show()
	
	disable_menu()
	Global.CURRENT_LEVEL = level
	Global.goto_scene(scene)
	print("[CRUS ONLINE / CLIENT]: Goto to scene [" + scene + "]")
	
	Players.load_players()

func _scene_loaded():
	if not player_scene_loaded:
		$SyncLoad.rect_scale = Vector2(Global.resolution[0] / 1280 ,Global.resolution[1] / 720 )
		$SyncLoad.show()
		player_scene_loaded = true
		get_tree().paused = true
		
		if NetworkBridge.n_is_network_master(self):
			loaded_players.append(NetworkBridge.get_host_id())
			connect("host_tick", self, "check_players_load")
		else:
			NetworkBridge.n_rpc(self, "load_check")

func check_players_load():
	var is_players_loaded = true

	for player in players:
		if not loaded_players.has(player):
			is_players_loaded = false
	
	if is_players_loaded:
		disconnect("host_tick", self, "check_players_load")
		
		print("[CRUS ONLINE / HOST]: Scene loaded")
		
		get_tree().paused = false
		$SyncLoad.hide()
		emit_signal("scene_loaded")
		NetworkBridge.n_rpc(self, "scene_loaded_signal")

master func load_check(id):
	loaded_players.append(id)

puppet func scene_loaded_signal(id):
	get_tree().paused = false
	$SyncLoad.hide()
	emit_signal("scene_loaded")
	
	print("[CRUS ONLINE / CLIENT]: Scene loaded")

################################################################################

var died_players = []

func player_died():
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		_player_died(true)
	else:
		NetworkBridge.n_rpc(self, "_player_died")

master func _player_died(id, host = false):
	if host:
		if not died_players.has(NetworkBridge.get_host_id()):
			died_players.append(NetworkBridge.get_host_id())
	else:
		if not died_players.has(id):
			died_players.append(id)
	
	var all_player_died = true

	for player in players:
		if not died_players.has(player):
			all_player_died = false
	
	if all_player_died:
		print("[CRUS ONLINE / HOST]: All players is dead lol")
		$RestartTimer.start()
		set_death_label(null)
		NetworkBridge.n_rpc(self, "set_death_label")

puppet func set_death_label(id):
	DeathScreen.set_death_label()

func restart_map():
	hide_death_screen(null)
	NetworkBridge.n_rpc(self, "hide_death_screen")
	goto_scene_host(hostSettings.map)

puppet func hide_death_screen(id):
	DeathScreen.hide()
	if playerPuppet != null:
		playerPuppet.respawn_puppet()

func player_respawn():
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		_player_respawn(true)
	else:
		NetworkBridge.n_rpc(self, "_player_respawn")

master func _player_respawn(id, host = false):
	if host:
		if died_players.has(NetworkBridge.get_host_id()):
			died_players.erase(NetworkBridge.get_host_id())
	else:
		if died_players.has(id):
			died_players.erase(id)

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
	if not NetworkBridge.check_connection():
		NetworkBridge.set_mode(0)
		host_server()
	
	if NetworkBridge.n_is_network_master(self):
		goto_scene_host(level)
		return true
	return false
