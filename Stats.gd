extends PanelContainer

onready var Multiplayer = Global.get_node("Multiplayer")
onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

onready var playersList = $VBoxContainer/PanelContainer/RichTextLabel

var sizeRatio = 16

func _ready():
	hide()

func set_size_ratio():
	sizeRatio = 16 * (Global.resolution[0] / 1280)
	
	$VBoxContainer/PanelContainer/RichTextLabel.get_font("normal_font").size = sizeRatio
	$VBoxContainer/Label.get_font("font").size = sizeRatio

func open_stats(type):
	show()
	set_size_ratio()
	$"../OpenStats".button_disable()
	$"../CloseStats".button_enable()

func close_stats(type):
	hide()
	$"../OpenStats".button_enable()
	$"../CloseStats".button_disable()

var tick = 0

func _physics_process(delta):
	if visible and $"..".visible:
		tick += 1
		if tick % 15 == 0:
			var playerNumber = 1
			playersList.bbcode_text = ""
			
			for player in Multiplayer.players:
				playersList.bbcode_text += str(playerNumber) + ": [color=#" + Multiplayer.players[player].color + "]" + Multiplayer.players[player].nickname + "[/color]"
				
				if player == NetworkBridge.get_host_id():
					playersList.bbcode_text += " (host)\n"
				else:
					playersList.bbcode_text += "\n"
				
				playerNumber += 1
				
				$VBoxContainer/PanelContainer/RichTextLabel.text += player.nickname
			
			print(playersList.bbcode_text)
			tick = 0
