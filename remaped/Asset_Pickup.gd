extends Area

# WARN: По какой-то причине загружается до инициализации стима

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

export  var value = "Liver"

func _ready():
	NetworkBridge.register_rpcs(self, [
		["hide_asset", NetworkBridge.PERMISSION.ALL]
	])

func player_use():
	Global.player.UI.notify(value + " acquisition complete", Color(1, 1, 0))
	for stock in Global.STOCKS.stocks:
		if stock.s_name == value:
			stock.owned += 1
	if Global.STOCKS.ORGANS_FOUND.find(value) == - 1:
		Global.STOCKS.ORGANS_FOUND.append(value)
	Global.STOCKS.save_stocks("user://stocks.save")
	NetworkBridge.n_rpc(self, "hide_asset")
	get_parent().queue_free()

remote func hide_asset(id):
	get_parent().queue_free()
