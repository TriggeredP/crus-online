extends Spatial

onready var Multiplayer = Global.get_node("Multiplayer")

func player_use():
	if is_network_master():
		Multiplayer.goto_menu_host()
