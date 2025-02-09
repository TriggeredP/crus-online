extends Spatial

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

onready var Multiplayer = Global.get_node("Multiplayer")

func player_use():
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		Multiplayer.goto_menu_host()
