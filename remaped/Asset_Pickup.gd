extends Area

export  var value = "Liver"

func player_use():
	Global.player.UI.notify(value + " acquisition complete", Color(1, 1, 0))
	for stock in Global.STOCKS.stocks:
		if stock.s_name == value:
			stock.owned += 1
	if Global.STOCKS.ORGANS_FOUND.find(value) == - 1:
		Global.STOCKS.ORGANS_FOUND.append(value)
	Global.STOCKS.save_stocks("user://stocks.save")
	$CollisionShape.disabled = true
	get_parent().get_node("CollisionShape").disabled = true
	get_parent().hide()
