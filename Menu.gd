extends Control

onready var parent = get_parent()

func _ready():
	rect_scale = Vector2(Global.resolution[0] / 1280 ,Global.resolution[1] / 720 )
	hide()
	set_process_input(false)

func hide_menu(type = null):
	hide()
	get_parent().Hint.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.player.weapon.disabled = false
	
	Global.player.set_process(true)
	Global.player.set_physics_process(true)
	Global.player.set_process_input(true)
	Global.player.set_process_unhandled_key_input(true)

func show_menu(type = null):
	rect_scale = Vector2(Global.resolution[0] / 1280 ,Global.resolution[1] / 720 )
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.player.weapon.disabled = true
	
	Global.player.set_process(false)
	Global.player.set_physics_process(false)
	Global.player.set_process_input(false)
	Global.player.set_process_unhandled_key_input(false)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if visible:
			hide_menu()
		else:
			show_menu()

func leave_server(type):
	hide_menu()
	set_process_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	for child in parent.Players.get_children():
		child.queue_free()
	
	parent.goto_menu_client()
	parent.leave_server()
