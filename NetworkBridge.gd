extends Node

enum MULTIPLAYER_TYPE {LAN, STEAM}
enum RPC_MODE {CLIENT, SERVER}

export(MULTIPLAYER_TYPE) var multiplayer_mode = 0

onready var Multiplayer = Global.get_node("Multiplayer")
onready var SteamInit = Global.get_node("Multiplayer/SteamInit")
onready var SteamNetwork = Global.get_node("Multiplayer/SteamInit/SteamNetwork")
onready var SteamLobby = Global.get_node("Multiplayer/SteamInit/SteamLobby")

func set_mode(mode):
	match mode:
		MULTIPLAYER_TYPE.LAN:
			print("[CRUS ONLINE / NETWORK BRIDGE]: LAN mode selected")
			multiplayer_mode = MULTIPLAYER_TYPE.LAN
		MULTIPLAYER_TYPE.STEAM:
			print("[CRUS ONLINE / NETWORK BRIDGE]: Steam mode selected")
			multiplayer_mode = MULTIPLAYER_TYPE.STEAM
	
	#$"../PingTimer".start()

func is_lan():
	return multiplayer_mode == MULTIPLAYER_TYPE.LAN

func is_steam():
	return multiplayer_mode == MULTIPLAYER_TYPE.STEAM

func check_connection():
	match multiplayer_mode:
		MULTIPLAYER_TYPE.LAN:
			return get_tree().network_peer != null
		MULTIPLAYER_TYPE.STEAM:
			return SteamLobby.in_lobby()

func get_peers():
	return SteamNetwork.get_peers()

func r_is_network_master(node):
	match multiplayer_mode:
		MULTIPLAYER_TYPE.LAN:
			return node.is_network_master()
		MULTIPLAYER_TYPE.STEAM:
			return SteamNetwork.is_server()

func r_rpc(caller : Node, method = null, args = []):
	if method == null:
		return
	
	Multiplayer.packages_count += 1
	
	match multiplayer_mode:
		MULTIPLAYER_TYPE.LAN:
			var rpc_args = [method, get_tree().network_peer.get_unique_id()]
			rpc_args.append_array(args)
			caller.callv("rpc", rpc_args)
			#caller.rpc(method, get_tree().network_peer.get_unique_id(), args)
		MULTIPLAYER_TYPE.STEAM:
			if r_is_network_master(caller):
				SteamNetwork.rpc_all_clients(caller, method, args)
			else:
				SteamNetwork.rpc_on_server(caller, method, args)

func r_rpc_unreliable(caller : Node, method = null, args = []):
	if method == null:
		return
	
	match multiplayer_mode:
		MULTIPLAYER_TYPE.LAN:
			var rpc_args = [method, get_tree().network_peer.get_unique_id()]
			rpc_args.append_array(args)
			caller.callv("rpc_unreliable", rpc_args)
			#caller.rpc_unreliable(method, get_tree().network_peer.get_unique_id(), args)
			Multiplayer.packages_count += 1
		MULTIPLAYER_TYPE.STEAM:
			r_rpc(caller, method, args)

func r_rpc_id(caller : Node, id = 0, method = null, args = []):
	if method == null:
		return
	
	Multiplayer.packages_count += 1
	
	match multiplayer_mode:
		MULTIPLAYER_TYPE.LAN:
			var rpc_args = [id, method, get_tree().network_peer.get_unique_id()]
			rpc_args.append_array(args)
			caller.callv("rpc_id", rpc_args)
			#caller.rpc_id(id, method, get_tree().network_peer.get_unique_id(), args)
		MULTIPLAYER_TYPE.STEAM:
			SteamNetwork.rpc_on_client(int(id), caller, method, args)

func r_rpc_unreliable_id(caller : Node, id = 0, method = null, args = []):
	if method == null:
		return
	
	match multiplayer_mode:
		MULTIPLAYER_TYPE.LAN:
			var rpc_args = [id, method, get_tree().network_peer.get_unique_id()]
			rpc_args.append_array(args)
			caller.callv("rpc_unreliable_id", rpc_args)
			#caller.rpc_unreliable_id(id, method, get_tree().network_peer.get_unique_id(), args)
			Multiplayer.packages_count += 1
		MULTIPLAYER_TYPE.STEAM:
			r_rpc_id(caller, id, method, args)
