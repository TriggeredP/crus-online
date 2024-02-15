extends Area

export  var value = 10
export  var id = "N"

func _ready():
	if Global.MONEY_ITEMS.find(id) != - 1:
		get_parent().hide()
		$CollisionShape.disabled = true

func player_use():
	Global.player.UI.notify("$" + str(value) + " picked up", Color(1, 1, 0))
	Global.money += value
	if id != "N":
		Global.MONEY_ITEMS.append(id)
	Global.save_game()
	get_parent().hide()
	$CollisionShape.disabled = true
