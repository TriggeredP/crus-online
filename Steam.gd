extends Node

onready var Multiplayer = Global.get_node("Multiplayer")

onready var Steam = preload("res://addons/godotsteam/godotsteam.gdns").new()

var is_on_steam_deck: bool = false
var is_online: bool = false
var is_owned: bool = false
var steam_app_id: int = 1388770
var steam_id: int = 0
var steam_username: String = ""

onready var SteamNetwork = $SteamNetwork
onready var SteamLobby = $SteamLobby

func _ready() -> void:
	OS.set_environment("SteamAppId", str(steam_app_id))
	OS.set_environment("SteamGameId", str(steam_app_id))
	
	var args = OS.get_cmdline_args()

	if args.size() > 0:
		for arg in args:
			if arg == "+crus_online_debug_1":
				print("[ CRUS ONLINE / DEBUG ] ipc name: crus_online_debug_1")
				OS.set_environment("steam_master_ipc_name_override", "crus_online_debug_1")
			elif arg == "+crus_online_debug_2":
				print("[ CRUS ONLINE / DEBUG ] ipc name: crus_online_debug_2")
				OS.set_environment("steam_master_ipc_name_override", "crus_online_debug_2")

	var initialize_response = Steam.steamInit()
	
	print("[ CRUS ONLINE / STEAM ]\n")
	
	print("Did Steam initialize?: %s" % initialize_response)
	
#	if initialize_response['status'] > 0:
#		print("Failed to initialize Steam, shutting down: %s" % initialize_response)
#		get_tree().quit()
	
	is_on_steam_deck = Steam.isSteamRunningOnSteamDeck()
	is_online = Steam.loggedOn()
	is_owned = Steam.isSubscribed()
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	
	print("Is on steam deck?: %s" % is_on_steam_deck)
	print("Is online?: %s" % is_online)
	print("Is is owned?: %s" % is_owned)
	print("Steam ID: %s" % steam_id)
	print("Steam Username: %s" % steam_username)

	# Check if account owns the game
	if is_owned == false:
		print("User does not own this game")
		#get_tree().quit()
	
	print("\n[ CRUS ONLINE / STEAM ]")
	
	$SteamLobby.lobby_init()

func _process(_delta: float) -> void:
	Steam.run_callbacks()
