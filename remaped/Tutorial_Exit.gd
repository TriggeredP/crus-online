extends Spatial

onready var Multiplayer = Global.get_node("Multiplayer")

func player_use():
	if get_tree().network_peer != null and is_network_master():
		Multiplayer.goto_menu_host()
