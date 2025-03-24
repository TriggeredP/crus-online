extends PanelContainer

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

export var in_game_chat = true

onready var textBox = $VBoxContainer/PanelContainer/RichTextLabel
onready var lineEdit = $VBoxContainer/LineEdit
onready var labelText = $VBoxContainer/Label

onready var parent = Global.get_node("Multiplayer")

var sizeRatio = 16
var dragging = false
var drag_offset = Vector2()  # Offset between cursor and panel origin

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	NetworkBridge.register_rpcs(self,[
		["send_message_host", NetworkBridge.PERMISSION.ALL],
		["send_message", NetworkBridge.PERMISSION.SERVER]
	])
	
	if in_game_chat:
		hide()

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				var local_pos = event.position
				var header_height = labelText.rect_size.y if labelText else 30
				var header_rect = Rect2(Vector2(0, 0), Vector2(rect_size.x, header_height))
				
				if header_rect.has_point(local_pos):
					dragging = true
					drag_offset = get_global_mouse_position() - rect_global_position
					get_tree().set_input_as_handled()
			else:
				dragging = false
	
	elif event is InputEventMouseMotion and dragging:
		rect_global_position = get_global_mouse_position() - drag_offset
		
		var viewport_size = get_viewport_rect().size
		rect_position.x = clamp(rect_position.x, 0, viewport_size.x - rect_size.x * rect_scale.x)
		rect_position.y = clamp(rect_position.y, 0, viewport_size.y - rect_size.y * rect_scale.y)
		get_tree().set_input_as_handled()

func _process(delta):
	if dragging and not Input.is_mouse_button_pressed(BUTTON_LEFT):
		dragging = false

func set_size_ratio():
	sizeRatio = 16 * (Global.resolution[0] / 1280)
	
	textBox.get_font("normal_font").size = sizeRatio
	lineEdit.get_font("font").size = sizeRatio
	labelText.get_font("font").size = sizeRatio

master func send_message_host(id, message, author, img = "null", color = "ff0000"):
	NetworkBridge.n_rpc(self, "send_message", [message, author, img, color])
	send_message(null, message, author, img, color)

puppet func send_message(id, message, author, img = "null", color = "ff0000"):
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
		if NetworkBridge.n_is_network_master(self):
			send_message_host(null, new_text, parent.playerInfo.nickname, parent.playerInfo.image, parent.playerInfo.color)
		else:
			NetworkBridge.n_rpc(self, "send_message_host", [new_text, parent.playerInfo.nickname, parent.playerInfo.image, parent.playerInfo.color])
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

