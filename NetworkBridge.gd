extends Node

enum MULTIPLAYER_TYPE {LAN, STEAM}
enum RPC_MODE {CLIENT, SERVER}

# SERVER = PUPPET = Server -> Clients only
# ALL = REMOTE = Server <-> Clients

enum PERMISSION {SERVER, ALL}

export(MULTIPLAYER_TYPE) var multiplayer_mode = 0

onready var Multiplayer = Global.get_node("Multiplayer")
onready var SteamInit = Global.get_node("Multiplayer/SteamInit")
onready var SteamNetwork = Global.get_node("Multiplayer/SteamInit/SteamNetwork")
onready var SteamLobby = Global.get_node("Multiplayer/SteamInit/SteamLobby")

var debug = false

var rpc_debug_list = {}
var rset_debug_list = {}

func add_rpc_to_debug_list(caller, method):
	if debug and rpc_debug_list.has(method):
		rpc_debug_list[method] += 1
	else:
		rpc_debug_list[method] = 1

func add_rset_to_debug_list(caller, method):
	if debug and rset_debug_list.has(method):
		rset_debug_list[method] += 1
	else:
		rset_debug_list[method] = 1

var list_count = 0

func print_debug_list():
	list_count += 1
	
	print("\n[CRUS ONLINE / NETWORK BRIDGE / DEBUG]: Packages debug list #", list_count)
	
	if debug:
		if not rpc_debug_list.empty():
			print("RPC: ", rpc_debug_list)
			rpc_debug_list = {}

		if not rset_debug_list.empty():
			print("RSET: ", rset_debug_list, "\n")
			rset_debug_list = {}

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

func get_id():
	match multiplayer_mode:
		MULTIPLAYER_TYPE.LAN:
			return get_tree().get_network_unique_id()
		MULTIPLAYER_TYPE.STEAM:
			return SteamInit.steam_id

func get_host_id():
	match multiplayer_mode:
		MULTIPLAYER_TYPE.LAN:
			return 1
		MULTIPLAYER_TYPE.STEAM:
			return SteamLobby.get_lobby_owner()

func n_is_network_master(node):
	match multiplayer_mode:
		MULTIPLAYER_TYPE.LAN:
			return node.is_network_master()
		MULTIPLAYER_TYPE.STEAM:
			return SteamNetwork.is_server()

# Some nodes register before this node's _ready has run, while the onready vars
# are still null. Calling a method on null segfaults in release builds, so look
# SteamNetwork up directly; registering only fills its table, which is safe this early
func _get_steam_network():
	if SteamNetwork == null:
		SteamNetwork = Global.get_node_or_null("Multiplayer/SteamInit/SteamNetwork")
	return SteamNetwork

# Setting global_transform updates the physics server and every child node even
# when nothing moved, and puppets used to do it every frame forever (every NPC,
# and every gib and prop ever spawned). Only move while catching up with the
# synced transform, then snap onto it and stop until the next update arrives
func approach_transform(node : Spatial, target : Transform, delta : float):
	var current = node.global_transform
	if _transforms_close(current, target):
		return
	var next = current.interpolate_with(target, delta * 10.0)
	if _transforms_close(next, target):
		next = target
	node.global_transform = next

func _transforms_close(a : Transform, b : Transform) -> bool:
	return a.origin.distance_squared_to(b.origin) < 0.000001 \
		and a.basis.x.distance_squared_to(b.basis.x) < 0.000001 \
		and a.basis.y.distance_squared_to(b.basis.y) < 0.000001 \
		and a.basis.z.distance_squared_to(b.basis.z) < 0.000001

func check_rpc(caller : Node, method = ""):
	var network = _get_steam_network()
	return network != null and network.check_permission_hash(caller, method)

# Registration only fills a lookup table, so it doesn't need Steam to be logged in.
# Skipping it made check_rpc fail forever, and physics objects re-registered
# (and printed) every few frames as a result
func register_rpcs(caller : Node, args):
	var network = _get_steam_network()
	if network != null:
		network.register_rpcs(caller, args)

func register_rset(caller : Node, method, recived_permission):
	var network = _get_steam_network()
	if network != null:
		network.register_rset(caller, method, recived_permission)

func n_rpc(caller : Node, method = null, args = []):
	if method == null:
		return
	
	Multiplayer.packages_count += 1
	
	match multiplayer_mode:
		MULTIPLAYER_TYPE.LAN:
			add_rpc_to_debug_list(caller, method)
			var rpc_args = [method, get_tree().network_peer.get_unique_id()]
			rpc_args.append_array(args)
			caller.callv("rpc", rpc_args)
			#caller.rpc(method, get_tree().network_peer.get_unique_id(), args)
		MULTIPLAYER_TYPE.STEAM:
			add_rpc_to_debug_list(caller, method)
			if SteamNetwork.is_server():
				SteamNetwork.rpc_all_clients(caller, method, args)
			else:
				SteamNetwork.rpc_on_server(caller, method, args)

func n_rpc_unreliable(caller : Node, method = null, args = []):
	if method == null:
		return
	
	match multiplayer_mode:
		MULTIPLAYER_TYPE.LAN:
			add_rpc_to_debug_list(caller, method)
			var rpc_args = [method, get_tree().network_peer.get_unique_id()]
			rpc_args.append_array(args)
			caller.callv("rpc_unreliable", rpc_args)
			#caller.rpc_unreliable(method, get_tree().network_peer.get_unique_id(), args)
			Multiplayer.packages_count += 1
		MULTIPLAYER_TYPE.STEAM:
			add_rpc_to_debug_list(caller, method)
			Multiplayer.packages_count += 1
			if SteamNetwork.is_server():
				SteamNetwork.rpc_all_clients(caller, method, args, false)
			else:
				SteamNetwork.rpc_on_server(caller, method, args, false)

func n_rpc_id(caller : Node, id = 0, method = null, args = []):
	if method == null:
		return
	
	Multiplayer.packages_count += 1
	
	match multiplayer_mode:
		MULTIPLAYER_TYPE.LAN:
			add_rpc_to_debug_list(caller, method)
			var rpc_args = [id, method, get_tree().network_peer.get_unique_id()]
			rpc_args.append_array(args)
			caller.callv("rpc_id", rpc_args)
			#caller.rpc_id(id, method, get_tree().network_peer.get_unique_id(), args)
		MULTIPLAYER_TYPE.STEAM:
			add_rpc_to_debug_list(caller, method)
			if SteamNetwork.is_server():
				SteamNetwork.rpc_on_client(int(id), caller, method, args)
			else:
				SteamNetwork.rpc_on_server(caller, method, args)

func n_rpc_unreliable_id(caller : Node, id = 0, method = null, args = []):
	if method == null:
		return
	
	match multiplayer_mode:
		MULTIPLAYER_TYPE.LAN:
			add_rpc_to_debug_list(caller, method)
			var rpc_args = [id, method, get_tree().network_peer.get_unique_id()]
			rpc_args.append_array(args)
			caller.callv("rpc_unreliable_id", rpc_args)
			#caller.rpc_unreliable_id(id, method, get_tree().network_peer.get_unique_id(), args)
			Multiplayer.packages_count += 1
		MULTIPLAYER_TYPE.STEAM:
			add_rpc_to_debug_list(caller, method)
			Multiplayer.packages_count += 1
			if SteamNetwork.is_server():
				SteamNetwork.rpc_on_client(int(id), caller, method, args, false)
			else:
				SteamNetwork.rpc_on_server(caller, method, args, false)

func n_rset(caller : Node, method = null, recived_value = null):
	if method == null:
		return
	
	Multiplayer.packages_count += 1
	
	match multiplayer_mode:
		MULTIPLAYER_TYPE.LAN:
			add_rset_to_debug_list(caller, method)
			caller.rset(method, recived_value)
		MULTIPLAYER_TYPE.STEAM:
			add_rset_to_debug_list(caller, method)
			SteamNetwork.remote_set(caller, method, recived_value)

func n_rset_unreliable(caller : Node, method = null, recived_value = null):
	if method == null:
		return
	
	Multiplayer.packages_count += 1
	
	match multiplayer_mode:
		MULTIPLAYER_TYPE.LAN:
			add_rset_to_debug_list(caller, method)
			caller.rset_unreliable(method, recived_value)
		MULTIPLAYER_TYPE.STEAM:
			add_rset_to_debug_list(caller, method)
			SteamNetwork.remote_set(caller, method, recived_value, false)
