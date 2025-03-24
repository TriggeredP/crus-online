extends PanelContainer

onready var Multiplayer = Global.get_node("Multiplayer")
onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

onready var playersList = $VBoxContainer/PanelContainer/RichTextLabel

var sizeRatio = 16

var dragging = false
var drag_offset = Vector2()  # Offset between cursor and panel origin

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				var local_pos = event.position
				var label = $VBoxContainer/Label
				var header_height = label.rect_size.y if label else 30
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

