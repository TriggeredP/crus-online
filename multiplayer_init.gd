extends Node

func _init():
	ProjectSettings.set_setting("debug/gdscript/warnings/enable", true)
	
	Global.add_child(preload("res://MOD_CONTENT/CruS Online/multiplayer.tscn").instance())
	Global.add_child(preload("res://MOD_CONTENT/CruS Online/death_screen.tscn").instance())
	Global.get_node("Menu").add_child(preload("res://MOD_CONTENT/CruS Online/menu.tscn").instance())

	# $'/root/Global/Multiplayer'
	# Global.get_node('Multiplayer')
	# get_tree().get_nodes_in_group("Multiplayer")[0]
