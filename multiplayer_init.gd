extends Node

func _init():
	Global.add_child(preload("res://MOD_CONTENT/CruS Online/multiplayer.tscn").instance())
	Global.add_child(preload("res://MOD_CONTENT/CruS Online/death_screen.tscn").instance())
	Global.get_node("Menu").add_child(preload("res://MOD_CONTENT/CruS Online/menu.tscn").instance())
