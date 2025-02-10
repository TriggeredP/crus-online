extends Area

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

export  var value = 10
export  var id = "N"

var fromSlotMachine = false

func _ready():
	NetworkBridge.register_rpcs(self, [
		["hide_coin", NetworkBridge.PERMISSION.ALL]
	])
	
	if Global.MONEY_ITEMS.find(id) != - 1:
		get_parent().queue_free()

func player_use():
	Global.player.UI.notify("$" + str(value) + " picked up", Color(1, 1, 0))
	Global.money += value
	if id != "N":
		Global.MONEY_ITEMS.append(id)
	Global.save_game()
	
	if fromSlotMachine:
		NetworkBridge.n_rpc(self, "hide_coin")
	get_parent().queue_free()

remote func hide_coin(id):
	get_parent().queue_free()
