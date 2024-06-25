extends Control

func _ready():
	rect_scale = Vector2(Global.resolution[0] / 1280 ,Global.resolution[1] / 720 )
	hide()
	set_process_input(false)

func hide_menu(type = null):
	hide()
	get_parent().Hint.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.player.weapon.inMenu = false

func show_menu(type = null):
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.player.weapon.inMenu = true

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if visible:
			hide_menu()
		else:
			show_menu()

func leave_server(type):
	var parent = get_parent()
	
	get_tree().network_peer = null
	
	parent.goto_menu_client()
	
	hide_menu()
	set_process_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	parent.dataLoaded = false

	for child in parent.Players.get_children():
		child.queue_free()
