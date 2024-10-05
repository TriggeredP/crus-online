extends PanelContainer

export var in_game_chat = true

onready var textBox = $VBoxContainer/PanelContainer/RichTextLabel
onready var lineEdit = $VBoxContainer/LineEdit
onready var labelText = $VBoxContainer/Label

onready var parent = Global.get_node("Multiplayer")

var sizeRatio = 16

func _ready():
	if in_game_chat:
		hide()

func set_size_ratio():
	sizeRatio = 16 * (Global.resolution[0] / 1280)
	
	textBox.get_font("normal_font").size = sizeRatio
	lineEdit.get_font("font").size = sizeRatio
	labelText.get_font("font").size = sizeRatio

remote func send_message(message, author, img = "null", color = "ff0000"):
	var rawText = '\n'
	
	if img != "null":
		rawText = rawText + '[img=32]' + img + '[/img] '
	
	if color != "ff0000":
		rawText = rawText + '[color=#' + color + ']'
	
	rawText = rawText + author + ': ' + message
	
	textBox.bbcode_text = textBox.bbcode_text + rawText
	$AudioStreamPlayer.play()
	
	if in_game_chat:
		Global.UI.notify(message, Color(1, 0, 0))
		Global.UI.notify(author + ":", Color(color))

func _text_entered(new_text):
	if new_text != "":
		rpc_unreliable("send_message", new_text, parent.playerInfo.nickname, parent.playerInfo.image, parent.playerInfo.color)
		send_message(new_text, parent.playerInfo.nickname, parent.playerInfo.image, parent.playerInfo.color)
		lineEdit.text = ""

func open_chat(type):
	show()
	set_size_ratio()
	$"../OpenChat".button_disable()
	$"../CloseChat".button_enable()

func close_chat(type):
	hide()
	$"../OpenChat".button_enable()
	$"../CloseChat".button_disable()
