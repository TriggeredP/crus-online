extends PanelContainer

func _ready():
	hide()

func open_stats(type):
	show()
	$"../OpenStats".button_disable()
	$"../CloseStats".button_enable()

func close_stats(type):
	hide()
	$"../OpenStats".button_enable()
	$"../CloseStats".button_disable()
