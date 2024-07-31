extends Area

export (String, MULTILINE) var message = "N/A"
export  var tutorial = false

func _ready():
	if tutorial and Global.LEVELS_UNLOCKED > 1:
		queue_free()

func _on_Message_Area_body_entered(body):
	if body == Global.player:
		body.UI.message(message, false)
		queue_free()
