extends Container

onready var Multiplayer = Global.get_node("Multiplayer")

func multiplayer_exit():
	visible = true
	in_game = false
	menu[START].show()
	#hide_buttons(menu[START], 3, 5)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func multiplayer_enter():
	visible = false
	in_game = true
	menu[START].hide()
	#hide_buttons(menu[START], 2, 4)
	$Hover_Panel.hide()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

enum {UP, RIGHT, DOWN, LEFT}
enum {KEY_FORWARD, KEY_LEFT, KEY_RIGHT, KEY_BACK, KEY_SHOOT, KEY_JUMP, KEY_CROUCH, KEY_RELOAD, KEY_ZOOM, KEY_USE, KEY_KICK, KEY_LEAN_LEFT, KEY_LEAN_RIGHT, KEY_WEAPON1, KEY_WEAPON2, KEY_LAST_WEAPON, KEY_TERTIARY, KEY_THROW_WEAPON, KEY_SUICIDE, KEY_STOCKS}
enum {START, LEVEL_SELECT, WEAPON_SELECT, IN_GAME, LEVEL_END, SETTINGS, CHARACTER, STOCKS}
var confirmed = false
var cancel = false
enum {B_START, B_SETTINGS, B_QUIT, B_LEVEL, B_MISSION_START, 
	B_WEAPON_1, B_WEAPON_2, B_CHARACTER, B_STOCKS, B_W_PISTOL, B_W_SMG, B_W_SHOTGUN, B_W_RL, B_W_SNIPER, B_W_AR, B_W_S_SMG, B_W_NAMBU, 
	B_W_GAS_LAUNCHER, B_W_MG3, B_W_AUTOSHOTGUN, B_W_MAUSER, B_W_BORE, B_W_MKR, B_W_RADGUN, B_W_TRANQ, B_W_BLACKJACK, B_W_FLASHLIGHT, B_W_ZIPPY, B_W_AN94, B_W_VAG72, B_W_STEYR, B_W_CANCER, B_W_ROD, B_W_FLAMETHROWER, B_W_SKS, B_W_NAILER, B_W_SHOCK, B_W_LIGHT, B_EX_MENU, B_EX_LEVEL_SELECT, B_RETURN, B_RETRY, B_BONUS,
	B_MULTIPLAYER_MENU}
const BUTTON_TEXTURES:Array = [preload("res://Textures/Menu/start_normal.png"), 
									preload("res://Textures/Menu/settings_normal.png"), 
									preload("res://Textures/Menu/OS_normal.png"), 
									preload("res://Textures/Menu/implant_menu_button.png"), 
									preload("res://Textures/Menu/mission_start.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Menu/implant_menu_button.png"), 
									preload("res://Textures/Menu/stock.png"), 
									preload("res://Textures/Menu/Weapon_Buttons/Pistol.png"), 
									preload("res://Textures/Menu/Weapon_Buttons/SMG.png"), 
									preload("res://Textures/Menu/Weapon_Buttons/Shotgun.png"), 
									preload("res://Textures/Menu/Weapon_Buttons/RL.png"), 
									preload("res://Textures/Menu/Weapon_Buttons/Sniper.png"), 
									preload("res://Textures/Menu/Weapon_Buttons/AR.png"), 
									preload("res://Textures/Menu/Weapon_Buttons/S_SMG.png"), 
									preload("res://Textures/Menu/Weapon_Buttons/Nambu.png"), 
									preload("res://Textures/Menu/Weapon_Buttons/Gas_Launcher.png"), 
									preload("res://Textures/Menu/Weapon_Buttons/MG3.png"), 
									preload("res://Textures/Menu/Weapon_Buttons/Autoshotgun.png"), 
									preload("res://Textures/Menu/Weapon_Buttons/Mauser.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/Bore.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/MKR.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/radgun.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/tranq.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/baton.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/flashlight.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/zippy.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/AN94.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/vag72.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/steyr.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/dna.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/rod.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/flamethrower.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/SKS.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/nailer.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/shockwave.png"), 
								preload("res://Textures/Menu/Weapon_Buttons/light.png"), 
									preload("res://Textures/Menu/exit_menu_normal.png"), 
									preload("res://Textures/Menu/exit_level_normal.png"), 
									preload("res://Textures/Menu/return_normal.png"), 
									preload("res://Textures/Menu/retry_normal.png"), 
									preload("res://Textures/Menu/retry_normal.png"),
									preload("res://Textures/Menu/retry_normal.png"),
									preload("res://MOD_CONTENT/CruS Online/icon.png")
								]
const WEAPON_PROFILES:Array = [preload("res://Textures/Menu/Weapon_Profiles/Pistol.png"), 
								preload("res://Textures/Menu/Weapon_Profiles/SMG.png"), 
								preload("res://Textures/Menu/Weapon_Profiles/Shotgun.png"), 
								preload("res://Textures/Menu/Weapon_Profiles/RL.png"), 
								preload("res://Textures/Menu/Weapon_Profiles/Sniper.png"), 
								preload("res://Textures/Menu/Weapon_Profiles/AR.png"), 
								preload("res://Textures/Menu/Weapon_Profiles/S_SMG.png"), 
								preload("res://Textures/Menu/Weapon_Profiles/S_SMG.png"), 
								preload("res://Textures/Menu/Weapon_Profiles/S_SMG.png"), 
								preload("res://Textures/Menu/Weapon_Profiles/S_SMG.png"), 
								preload("res://Textures/Menu/Weapon_Profiles/S_SMG.png"), 
								preload("res://Textures/Menu/Weapon_Profiles/S_SMG.png"), 
								preload("res://Textures/Menu/Weapon_Profiles/S_SMG.png"), 
								preload("res://Textures/Menu/Weapon_Profiles/S_SMG.png")]
const BUTTON_TEXTURES_H:Array = [preload("res://Textures/Menu/hover.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
								]
const BUTTON_TEXTURES_P:Array = [preload("res://Textures/Menu/hover.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
									preload("res://Textures/Items/medkit1.png"), 
								]
const BUTTON_TEXTURES_D:Array = [preload("res://Textures/Menu/Disabled_Button/1.png"), 
								preload("res://Textures/Menu/Disabled_Button/2.png"), 
								preload("res://Textures/Menu/Disabled_Button/3.png"), 
								preload("res://Textures/Menu/Disabled_Button/4.png")]
const MYSTERY = preload("res://Textures/Menu/mystery.png")
enum {W_PISTOL, W_SMG, W_TRANQ, W_BLACKJACK, W_SHOTGUN, W_RL, W_SNIPER, W_AR, W_S_SMG, W_NAMBU, W_GAS_LAUNCHER, W_MG3, W_AUTOSHOTGUN, W_MAUSER, W_BORE, W_MKR, W_RADIATOR, W_FLASHLIGHT, W_ZIPPY, W_AN94, W_VAG72, W_STEYR, W_CANCER, W_ROD, W_FLAMETHROWER, W_SKS, W_NAILER, W_SHOCK, W_LIGHT}
const RESOLUTIONS:Array = [Vector2(1920, 1080), Vector2(1600, 900), Vector2(1366, 768), Vector2(1280, 720), Vector2(3840, 2160), Vector2(2560, 1440), Vector2(3840, 2400), Vector2(2560, 1600), Vector2(1920, 1200), Vector2(1680, 1050), Vector2(1440, 900), Vector2(3440, 1440), Vector2(2880, 1200), Vector2(2560, 1080), Vector2(1920, 800), Vector2(1600, 1200), Vector2(1440, 1080), Vector2(1024, 768), Vector2(800, 600), Vector2(640, 480), Vector2(1080, 1080)]
const RANK_LETTERS:Array = [preload("res://Textures/rank_letters/C.png"), 
preload("res://Textures/rank_letters/B.png"), 
preload("res://Textures/rank_letters/A.png"), 
preload("res://Textures/rank_letters/S.png"), 
preload("res://Textures/rank_letters/N.png")]
var LEVEL_NAMES:Array = ["Training Facility", "Headquarters", "Suburb", "Spaceport", "PD", "Mall", "Apartment", "Ship", "Swamp", "Casino", "Castle", "Office", "Archon Grid", "NEED", "HELP", "END", "PAIN", "NOW", "AAAAAA"]

const HANDLER_FRAMES:Array = [preload("res://Textures/Menu/Handler/1.png"), 
								preload("res://Textures/Menu/Handler/2.png"), 
								preload("res://Textures/Menu/Handler/3.png"), 
								preload("res://Textures/Menu/Handler/4.png")]
var key_pressed
var wait_for_key = false
var menu_dir:Array = [2, 
								1, 
								0, 
								3, 
								2, 
								1, 
								1, 
						2, 
						3, 
						3, 
						3
						]
var level_select_dir:Array = [2, 
								2, 
								1, 
								2, 
								3, 
								2, 
								1, 
						1, 
						1, 
						1, 
						2, 
						3, 
						3, 
						3, 
						3, 
						2, 
						1, 
						1, 
						1, 
						1, 
						2, 
						3, 
						3, 
						3, 
						3
						]
var menu:Array = []
var active_menus:Array = []
var active_element:Control
var level_buttons:Array = []
var current_menu = 0
var current_weapon_select = 0
var weapon_1 = 0
var weapon_2 = 1
var weapon_select_buttons:Array = []
var previous_menu = 0
var menu_button:Array = []
var button_size = Vector2(64, 64)
var b_position = Vector2(100, 100)
var dir = 0
var in_game = false

var resolution_list:ItemList
var time = 0
var all_buttons:Array
var hover_info
var menu_creation_level_index:int = 0
var menu_changing = false
onready var clear_button = $Settings / GridContainer / PanelContainer6 / VBoxContainer3 / ClearSave
class Menu extends Control:
	var buttons:Array
	var elements:Array

func _physics_process(delta):
	time += 1
	
	if in_game:
		clear_button.hide()
	else :
		clear_button.show()
	
	
	
	
	
	
	hover_info.get_parent().rect_global_position = get_global_mouse_position() + Vector2(50, 20)
	hover_info.get_parent().rect_global_position.y = clamp(hover_info.get_parent().rect_global_position.y, 0, (720 - hover_info.get_parent().rect_size.y - 100) * rect_scale.x)
	hover_info.get_parent().rect_global_position.x = clamp(hover_info.get_parent().rect_global_position.x, 0, (1280 - hover_info.get_parent().rect_size.x - 100) * rect_scale.y)
	
	
	
	
	for button in all_buttons:
		for b in level_buttons:
			if button == b:
				return 
		if button.disabled:
			button.texture_disabled = BUTTON_TEXTURES_D[int(sin(button.get_index() + time * 0.05) * 3) % 3]

func get_key_index(action):
	if action is InputEventKey:
		return [action.scancode, "KEY"]
	elif action is InputEventMouseButton:
		return [action.button_index, "MOUSE"]
func get_scancodes():
	var key_scancodes:Array = [get_key_index(InputMap.get_action_list("movement_forward")[0]), 
	get_key_index(InputMap.get_action_list("movement_left")[0]), 
	get_key_index(InputMap.get_action_list("movement_right")[0]), 
	get_key_index(InputMap.get_action_list("movement_backward")[0]), 
	get_key_index(InputMap.get_action_list("mouse_1")[0]), 
	get_key_index(InputMap.get_action_list("movement_jump")[0]), 
	get_key_index(InputMap.get_action_list("crouch")[0]), 
	get_key_index(InputMap.get_action_list("reload")[0]), 
	get_key_index(InputMap.get_action_list("zoom")[0]), 
	get_key_index(InputMap.get_action_list("Use")[0]), 
	get_key_index(InputMap.get_action_list("kick")[0]), 
	get_key_index(InputMap.get_action_list("Lean_Left")[0]), 
	get_key_index(InputMap.get_action_list("Lean_Right")[0]), 
	get_key_index(InputMap.get_action_list("weapon1")[0]), 
	get_key_index(InputMap.get_action_list("weapon2")[0]), 
	get_key_index(InputMap.get_action_list("switch_weapon")[0]), 
	get_key_index(InputMap.get_action_list("Tertiary_Weapon")[0]), 
	get_key_index(InputMap.get_action_list("drop")[0]), 
	get_key_index(InputMap.get_action_list("Suicide")[0]), 
	get_key_index(InputMap.get_action_list("Stocks")[0])]
	return key_scancodes

func _ready():
	if Global.ending_3:
		$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / Chaos_Mode.show()
	else :
		$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / Chaos_Mode.hide()
	$Settings / GridContainer / PanelContainer6 / VBoxContainer3 / Timer.pressed = Global.timer
	$Settings / GridContainer / PanelContainer6 / VBoxContainer3 / Highperformance.pressed = Global.high_performance
	Global.screenmat.set_shader_param("gamma", Global.gamma)
	$Settings / GridContainer / PanelContainer / VBoxContainer / GAMMALABEL.text = "Gamma: " + str(Global.gamma)
	$"Settings/GridContainer/PanelContainer/VBoxContainer/Camera Sway".pressed = Global.camera_sway
	
	$Settings / GridContainer / PanelContainer5 / CheckBox.pressed = Global.full_screen
	if Global.full_screen:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(Global.resolution[0], Global.resolution[1]))
	$ConfirmationDialog.get_cancel().connect("pressed", self, "_on_Cancel_Pressed")
	$Settings / GridContainer / PanelContainer / VBoxContainer / InvertYAxis.pressed = Global.invert_y
	for level in range(Global.LEVELS.size()):
		var meta_file = File.new()
		meta_file.open(Global.LEVEL_META[level], File.READ)
		var parsed_level_meta:Dictionary = {}
		parsed_level_meta = parse_json(meta_file.get_as_text())
		LEVEL_NAMES[level] = parsed_level_meta.get("name")
		meta_file.close()
	$Settings / GridContainer / PanelContainer6 / VBoxContainer3 / Reflections.pressed = Global.reflections
	$Settings / GridContainer / PanelContainer6 / VBoxContainer3 / Draw_Label.text = "Draw Distance:\n" + str(Global.draw_distance)
	$Settings / GridContainer / PanelContainer6 / VBoxContainer3 / Drawslider.value = Global.draw_distance
	_on_Civslider_value_changed(Global.civilian_reduction)
	$Settings / GridContainer / PanelContainer6 / VBoxContainer3 / Civslider.value = Global.civilian_reduction
	$Level_Info_Grid / Level_Info_Vbox / Weapons_Vbox / TextureRect.texture = $Weapon1_Viewport.get_texture()
	$Level_Info_Grid / Level_Info_Vbox / Weapons_Vbox / TextureRect2.texture = $Weapon2_Viewport.get_texture()
	var keylist = $Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List
	keylist.add_item("Forward: " + InputMap.get_action_list("movement_forward")[0].as_text())
	keylist.add_item("Left: " + InputMap.get_action_list("movement_left")[0].as_text())
	keylist.add_item("Right: " + InputMap.get_action_list("movement_right")[0].as_text())
	keylist.add_item("Back: " + InputMap.get_action_list("movement_backward")[0].as_text())
	keylist.add_item("Shoot: " + InputMap.get_action_list("mouse_1")[0].as_text())
	keylist.add_item("Jump: " + InputMap.get_action_list("movement_jump")[0].as_text())
	keylist.add_item("Crouch: " + InputMap.get_action_list("crouch")[0].as_text())
	keylist.add_item("Reload: " + InputMap.get_action_list("reload")[0].as_text())
	keylist.add_item("Zoom: " + InputMap.get_action_list("zoom")[0].as_text())
	keylist.add_item("Use: " + InputMap.get_action_list("Use")[0].as_text())
	keylist.add_item("Kick: " + InputMap.get_action_list("kick")[0].as_text())
	keylist.add_item("Lean Left: " + InputMap.get_action_list("Lean_Left")[0].as_text())
	keylist.add_item("Lean Right: " + InputMap.get_action_list("Lean_Right")[0].as_text())
	keylist.add_item("Weapon 1: " + InputMap.get_action_list("weapon1")[0].as_text())
	keylist.add_item("Weapon 2: " + InputMap.get_action_list("weapon2")[0].as_text())
	keylist.add_item("Last Weapon: " + InputMap.get_action_list("switch_weapon")[0].as_text())
	keylist.add_item("Tertiary Weapon: " + InputMap.get_action_list("Tertiary_Weapon")[0].as_text())
	keylist.add_item("Throw Weapon: " + InputMap.get_action_list("drop")[0].as_text())
	keylist.add_item("Suicide: " + InputMap.get_action_list("Suicide")[0].as_text())
	keylist.add_item("Stock Market: " + InputMap.get_action_list("Stocks")[0].as_text())
	$MyWork.rect_global_position.x = 170
	$MyWork.rect_global_position.y = 248
	hover_info = $Hover_Panel / Hover_Info
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Title_Screen.rect_size = Vector2(512, 512)
	$Title_Screen.rect_global_position = Vector2(720, 128)
	$Level_Info_Grid.rect_size = Vector2(720, 720)
	$Level_Info_Grid.rect_global_position = Vector2(512, 0)
	
	$Character_Menu.rect_size = Vector2(1024, 512)
	$Character_Menu / Character_Container / TextureRect.rect_size = Vector2(384, 384)
	$Character_Menu.rect_global_position = Vector2(128, 128)
	$Character_Menu / Character_Container.rect_global_position = Vector2(256, 192)
	$Character_Menu / Character_Container / Equip_Grid.rect_size = Vector2(384, 384)
	$Character_Menu / Character_Container / TextureRect / Head_Button.rect_size = Vector2(48, 48)
	$Character_Menu / Character_Container / TextureRect / Head_Button.rect_position = Vector2(168, - 8)
	$Character_Menu / Character_Container / TextureRect / Torso_Button.rect_size = Vector2(48, 48)
	$Character_Menu / Character_Container / TextureRect / Torso_Button.rect_position = Vector2(168, 64)
	$Character_Menu / Character_Container / TextureRect / Leg_Button.rect_size = Vector2(48, 48)
	$Character_Menu / Character_Container / TextureRect / Leg_Button.rect_position = Vector2(64, 256)
	$Character_Menu / Character_Container / TextureRect / Arm_Button.rect_size = Vector2(48, 48)
	$Character_Menu / Character_Container / TextureRect / Arm_Button.rect_position = Vector2(64, 128)
	
	$Stock_Menu.rect_size = Vector2(1024, 512)
	$Stock_Menu / Character_Container / TextureRect.rect_size = Vector2(384, 384)
	$Stock_Menu.rect_global_position = Vector2(128, 128)
	$Stock_Menu / Character_Container.rect_global_position = Vector2(256, 192)
	$Stock_Menu / Character_Container.stocklist.rect_size = Vector2(384, 384)
	
	
	for button in $Level_End_Grid / Level_Info_Vbox.get_children():
		if button.get_class() == "TextureButton":
			button.connect("mouse_entered", self, "_on_mouse_entered", [0, button])
			button.connect("mouse_exited", self, "_on_mouse_exited", [0, button])
	
	for button in $Character_Menu / Character_Container / Equip_Grid.get_children():
		button.rect_size = Vector2(10, 10)
	
	for element in $Level_Info_Grid.get_children():
		element.rect_size = Vector2(240, 240)
	
	$Settings / GridContainer / PanelContainer / VBoxContainer / M_Sensitivity.value = Global.mouse_sensitivity * 100
	$Settings / GridContainer / PanelContainer3 / VBoxContainer2 / Master_Volume.value = Global.master_volume
	$Settings / GridContainer / PanelContainer3 / VBoxContainer2 / Music_Volume.value = Global.music_volume
	$Settings / GridContainer / PanelContainer / VBoxContainer / FOV.value = Global.FOV
	$Settings / GridContainer / PanelContainer / VBoxContainer / FOVLABEL.text = "FOV: " + str(Global.FOV)
	$Settings / GridContainer / PanelContainer6 / VBoxContainer3 / SkipIntro.pressed = Global.skip_intro
	$Settings / GridContainer / PanelContainer4 / VBoxContainer3 / Blood_Color_Rect.color = Global.blood_color
	$Settings / GridContainer / PanelContainer4 / VBoxContainer3 / HBoxContainer / R.value = Global.blood_color.r
	$Settings / GridContainer / PanelContainer4 / VBoxContainer3 / HBoxContainer2 / G.value = Global.blood_color.g
	$Settings / GridContainer / PanelContainer4 / VBoxContainer3 / HBoxContainer3 / B.value = Global.blood_color.b
	$Settings / GridContainer / PanelContainer4 / VBoxContainer3 / HBoxContainer4 / A.value = Global.blood_color.a
	
	resolution_list = $Settings / GridContainer / PanelContainer5 / Resolution_List
	for r in RESOLUTIONS:
		resolution_list.add_item(str(r.x) + "x" + str(r.y))
	for i in range(8):
		var new_menu = Menu.new()
		add_child(new_menu)
		menu.append(new_menu)



	
	menu[START].buttons = [B_START, B_MULTIPLAYER_MENU, B_SETTINGS, B_QUIT]
	menu[SETTINGS].buttons = [B_RETURN]
	menu[LEVEL_SELECT].buttons = [B_RETURN, B_CHARACTER, B_STOCKS, B_WEAPON_1, B_WEAPON_2, B_MISSION_START]
	for level in Global.LEVELS:
		menu[LEVEL_SELECT].buttons.append(B_LEVEL)
	
		
	menu[WEAPON_SELECT].buttons = [B_RETURN, B_W_PISTOL, B_W_SMG, B_W_TRANQ, B_W_BLACKJACK, B_W_SHOTGUN, B_W_RL, B_W_SNIPER, B_W_AR, B_W_S_SMG, B_W_NAMBU, B_W_GAS_LAUNCHER, B_W_MG3, B_W_AUTOSHOTGUN, B_W_MAUSER, B_W_BORE, B_W_MKR, B_W_RADGUN, B_W_FLASHLIGHT, B_W_ZIPPY, B_W_AN94, B_W_VAG72, B_W_STEYR, B_W_CANCER, B_W_ROD, B_W_FLAMETHROWER, B_W_SKS, B_W_NAILER, B_W_SHOCK, B_W_LIGHT]
	menu[CHARACTER].buttons = [B_RETURN]
	menu[STOCKS].buttons = [B_RETURN]
	
	active_menus.append(menu[START])
	
	for m in range(menu.size()):
		create_buttons(m)
	for child in menu[START].get_children():
		child.show()
		child.set_position(b_position)
		b_position.x += button_size.x
	update_level_info()
	
	
	#hide_buttons(menu[START], 3, 5)
	set_res(Global.resolution[0], Global.resolution[1])
	
	
func hide_buttons(m:Menu, a:int, b:int):
	for ab in range(a, b + 1):
		m.get_child(ab).hide()
	var s = m.get_children().size()
	for i in range(1, s):
		if m.get_child(i - 1).visible == false:
			for k in range(i, s):
				m.get_child(k).rect_position.x -= button_size.x

func show_buttons(m:Menu, a:int, b:int):
	var s = m.get_children().size()
	for i in range(0, s - 1):
		if m.get_child(i).visible == false:
			for k in range(i + 1, s):
				m.get_child(k).rect_position.x += button_size.x
	for ab in range(a, b + 1):
		m.get_child(ab).show()

func _on_Multiplayer_Button_Pressed(m:int, button_id:TextureButton):
	goto_menu(m, SETTINGS, button_id)
	get_tree().get_nodes_in_group("MultiplayerMenu")[0].enable_menu()

func create_buttons(m:int):
	var level = 0
	var bonus = 0
	for i in range(menu[m].buttons.size()):
		match menu[m].buttons[i]:
			B_RETRY:
				create_button(m, "Retry", "_on_Retry_Button_Pressed", menu[m].buttons[i])
			B_START:
				create_button(m, "Start", "_on_Start_Button_Pressed", menu[m].buttons[i])
			B_LEVEL:
				level_buttons.append(create_button(m, LEVEL_NAMES[level], "_on_Level_Pressed", menu[m].buttons[i]))
				level += 1
			
			B_MULTIPLAYER_MENU:
				create_button(m, "Cruelty Squad Online", "_on_Multiplayer_Button_Pressed", 44)
			
			B_SETTINGS:
				create_button(m, "Settings", "_on_Settings_Button_Pressed", menu[m].buttons[i])
			B_QUIT:
				create_button(m, "Quit", "_on_Quit_Button_Pressed", menu[m].buttons[i])
			B_EX_MENU:
				create_button(m, "Exit to Menu", "_on_Exit_Menu_Pressed", menu[m].buttons[i])
			B_EX_LEVEL_SELECT:
				create_button(m, "Exit to Level Select", "_on_Exit_Level_Select_Pressed", menu[m].buttons[i])
			B_RETURN:
				create_button(m, "Return", "_on_Return_Button_Pressed", menu[m].buttons[i])
			B_WEAPON_1:
				weapon_select_buttons.append(create_button(m, "Select Weapon 1", "_on_Weapon_1_Pressed", menu[m].buttons[i]))
			B_WEAPON_2:
				weapon_select_buttons.append(create_button(m, "Select Weapon 2", "_on_Weapon_2_Pressed", menu[m].buttons[i]))
			B_CHARACTER:
				create_button(m, "Equipment & Implants", "_on_Implants_Button_Pressed", menu[m].buttons[i])
			B_STOCKS:
				create_button(m, "Stock Market", "_on_Stocks_Button_Pressed", menu[m].buttons[i])
			B_W_PISTOL:
				var wep = create_button(m, "Parasonic D2 Silenced Pistol", "_on_Pistol_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "Uses special 10mm subsonic ammunition for extremely silent operation. Popular among high-end private security and wetworks services, as well as tactical wannabes."
			B_W_SMG:
				var wep = create_button(m, "K&H R5", "_on_SMG_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "One of the most widely used submachine guns since the 80s. Unmatched reliability and ease of operation."
			B_W_S_SMG:
				var wep = create_button(m, "Minato M9", "_on_S_SMG_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "Imported in great quantities by people of taste after being featured in the anime Haato no DokiDoki: Zankokudan."
			B_W_SHOTGUN:
				var wep = create_button(m, "Balotelli Hypernova", "_on_Shotgun_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "Following the rapid proliferation of advanced high quality body armor and the subsequent move from traditional buckshot to more effective flechette based shells, Belatelli Hypernova has proven to be the most cost effective solution."
			B_W_RL:
				var wep = create_button(m, "Security Systems Anti-Armor Device", "_on_RL_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "At some point arms manufacturer Security Systems managed to convince the world that it was absolutely necessary for corporate security to possess military-grade rocket launchers."
			B_W_SNIPER:
				var wep = create_button(m, "Stern AWS 3000", "_on_Sniper_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "The AWS 3000 uses a special sabot round with a 30 cm long depleted uranium penetrator. It is of course designed to counter armored targets but when it hits something soft it often tumbles and leaves more wound channel than target."
			B_W_AR:
				var wep = create_button(m, "K&H X20", "_on_AR_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "The Karl & Heinrich X20 immediately became a huge hit with elite security. It fires extremely accurate 3 round rapid fire bursts with very manageable recoil. The rounds are completely caseless meaning it can hold a large amount of ammunition without becoming cumbersome to carry, and doesn't leave behind as much evidence."
			B_W_NAMBU:
				var wep = create_button(m, "New Safety M62", "_on_Nambu_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "Standard police issue handgun for more than a hundred years. While more efficient options exist the cops have decided to stick with this due to masculine associations created by the film industry."
			B_W_GAS_LAUNCHER:
				var wep = create_button(m, "Riot Pacifier", "_on_Gas_Launcher_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "Fires a grenade filled with corrosive gas. Eats through almost everything. Hasn't seen much use since the food riots of the early 00s."
			B_W_MG3:
				var wep = create_button(m, "AMG4", "_on_MG3_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "Traditionally a weapon of the highly augmented military grunt, it has recently seen increasing use in the corporate setting. Extremely high rate of fire and good armor penetration thanks to the DU rounds it usually comes with."
			B_W_AUTOSHOTGUN:
				var wep = create_button(m, "Precise Industries AS15", "_on_Autoshotgun_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "A fully automatic shotgun capable of tearing almost everything into shreds up close. Complete overkill but popular with killers emotionally dulled by battle drugs."
			B_W_MAUSER:
				var wep = create_button(m, "Mowzer SP99", "_on_Mauser_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "Accurate and extremely silent bolt-action sniper rifle. Perfect for covert and illegal operations. An important symbol of the swamp cultist who claim to receive divine messages from them."
			B_W_BORE:
				var wep = create_button(m, "Security Systems Cerebral Bore", "_on_Bore_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "Security Systems have done it once again. This incredibly high tech vat grown bioweapon is itself a small biobreeder, capable of creating a small burrower flesh orb that goes for the target's head and empties it on the floor. For energy it sucks some life force out of the user. Neat huh?"
			B_W_MKR:
				var wep = create_button(m, "Spectacular Dynamics MCR Carbine", "_on_MKR_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "A futuristic microcaliber platform that never reached a huge popularity despite many advantages. Uses strange factory sealed disposable magazines and proprietary caseless ammunition."
			B_W_RADGUN:
				var wep = create_button(m, "Bolt ACR", "_on_Radgun_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "The goal of the Advanced Combat Rifle program was to create an energy weapon that wouldn't need to be reloaded at all. One of the results was this unfortunate portable gamma radiation emitter. Though often said to be illegal due to international agreements regarding radiation based weapons (no such agreements exist), the reason it never got much use is that most of the test subjects ended up accidentally killing themselves."
			B_W_TRANQ:
				var wep = create_button(m, "SNOOZEFEST Animal Control Pistol", "_on_Tranq_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "As the cost of human life is low, there has been no real attempt to create a tranquilizer gun for security or military needs. Some have however adopted these animal control pistols as a less messy way to get past overly vigilant security."
			B_W_BLACKJACK:
				var wep = create_button(m, "Expandable Baton", "_on_Blackjack_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "A standard device for knocking people out cold. The design has been the same since the early middle ages, only the materials have been improved."
			B_W_FLASHLIGHT:
				var wep = create_button(m, "Flashlight", "_on_Flashlight_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "A simple flashlight, not very useful. Or is it?"
			B_W_ZIPPY:
				var wep = create_button(m, "Zippy 3000", "_on_Zippy_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "The ultimate weapon, in ejection failures and misfires. You'll be lucky to get two shots out of this thing without blowing off your fingers."
			B_W_AN94:
				var wep = create_button(m, "BN-99", "_on_AN94_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "A mysterious weapon lost to time. Made out of an accursed alloy. Has a unique two shot burst firing mechanism."
			B_W_VAG72:
				var wep = create_button(m, "BAG-82", "_on_VAG72_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "Strange experimental caseless pistol created by an ancient civilization. Foul odour, who knows where this has been."
			B_W_STEYR:
				var wep = create_button(m, "Stern M17", "_on_Steyr_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "Winner of the advanced combat rifle program. Has widely replaced most other rifles in elite military use. Rapid three round burst of flechette rounds significantly increases hit probability."
			B_W_CANCER:
				var wep = create_button(m, "Parasonic C3 DNA Scrambler", "_on_DNA_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "High value targets often have immediate access to body reconstruction services and as such it has become a popular choice to mangle their genetic makeup beyond all repair with a hi-tech weapon like the Parasonic C3."
			B_W_ROD:
				var wep = create_button(m, "Fiberglass Fishing Rod", "_on_Rod_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "Enter the World of Fish and become who you were meant to be."
			B_W_FLAMETHROWER:
				var wep = create_button(m, "RPO-80 Sanitization System", "_on_FT_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "Janitorial work in the age of bioprinters and homebrew infectious disease follows these simple rules: Contain, Purify, Control."
			B_W_SKS:
				var wep = create_button(m, "ZKZ Transactional Rifle", "_on_SKS_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "Primordial weapon attuned to the beating heart of the financial system."
			B_W_NAILER:
				var wep = create_button(m, "Parasonic MP-1 Nailer", "_on_Nailer_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "Parasonic's new personal defense weapon provides never before seen firepower in a compact form factor. Fires ultra high velocity depleted uranium nails from a high-capacity helical magazine."
			B_W_SHOCK:
				var wep = create_button(m, "Raymond Shocktroop Tactical", "_on_Shock_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "A compact but powerful semi-automatic shotgun, popular in the law enforcement business for clearing out regenerative art communes."
			B_W_LIGHT:
				var wep = create_button(m, "Abscess Ironworks Lux ff374f727ce9d6d6e93be0793733c321", "_on_Light_Pressed", menu[m].buttons[i])
				wep.hint_tooltip = "Bask in the golden light of your radiant path."
			B_MISSION_START:
				create_button(m, "Start Mission", "_on_Mission_Start_Pressed", menu[m].buttons[i])
			_:
				print("BUTTON ERROR")

func create_button(m:int, n:String, connection:String, b:int):
	var new_button = TextureButton.new()
	menu[m].add_child(new_button)
	new_button.name = n
	new_button.texture_normal = BUTTON_TEXTURES[b]
	new_button.texture_hover = BUTTON_TEXTURES_H[0]
	new_button.texture_disabled = BUTTON_TEXTURES_D[randi() % 3]
	if b == B_LEVEL:
		
		var level_index = level_buttons.size()
		if level_index > Global.L_PUNISHMENT:
			new_button.texture_disabled = MYSTERY
		if Global.LEVEL_IMAGES.size() - 1 >= level_index:
			new_button.texture_normal = Global.LEVEL_IMAGES[level_index]
	if b == B_WEAPON_1:
		new_button.texture_normal = BUTTON_TEXTURES[B_W_PISTOL + weapon_1]
	if b == B_WEAPON_2:
		new_button.texture_normal = BUTTON_TEXTURES[B_W_PISTOL + weapon_2]
	
	new_button.expand = true
	new_button.set_position(b_position)
	new_button.rect_size = button_size
	new_button.connect("pressed", self, connection, [m, new_button])
	new_button.connect("mouse_exited", self, "_on_mouse_exited", [m, new_button])
	new_button.connect("mouse_entered", self, "_on_mouse_entered", [m, new_button])
	new_button.hide()
	all_buttons.append(new_button)
	return new_button
func _on_mouse_entered(m, button):
	if button.disabled:
		return 
	hover_info.get_node("Image").hide()
	hover_info.get_parent().raise()
	hover_info.get_node("Name").text = button.name
	hover_info.get_node("Hint").text = ""
	hover_info.get_parent().rect_size = Vector2(0, 0)
	if button.hint_tooltip != "":
		hover_info.get_node("Hint").show()
		hover_info.get_node("Hint").text = button.hint_tooltip
	else :
		hover_info.get_node("Hint").hide()
	if button.has_method("_get_name_override"):
		hover_info.get_node("Name").text = button._get_name_override()
	hover_info.get_parent().show()
func _on_mouse_exited(m, button):
	hover_info.get_parent().hide()
	hover_info.get_parent().rect_size = Vector2(0, 0)
	

func _on_Implants_Button_Pressed(m:int, button_id:TextureButton):
	goto_menu(m, CHARACTER, button_id)
	active_element = $Character_Menu
	$Character_Menu / Character_Container.update_buttons()
	$Character_Menu / Character_Container / TextureRect / Money.text = "$" + str(Global.money)
	$Character_Menu.raise()
	$Character_Menu.show()
	
	
	
	
	

func _on_Stocks_Button_Pressed(m:int, button_id:TextureButton):
	goto_menu(m, STOCKS, button_id)
	active_element = $Stock_Menu
	
	
	$Stock_Menu.raise()
	$Stock_Menu.show()
	
	
	
	
	


func _on_Start_Button_Pressed(m:int, button_id:TextureButton):
	Global.save_settings()
	if ( not in_game):
		goto_menu(m, LEVEL_SELECT, button_id)
		active_element = $Level_Info_Grid
		$Level_Info_Grid.rect_position.x = 512
		$Level_Info_Grid.rect_position.y = 40
		$Level_Info_Grid.come()
		$Level_Info_Grid / HBoxContainer / Description_Scroll / Description.speech_break = true
		$Level_Info_Grid / HBoxContainer / Description_Scroll / Description.visible_characters = 0
		for i in range(20):
			yield (get_tree(), "idle_frame")
		$Level_Info_Grid / HBoxContainer / Description_Scroll / Description.speech()
		$Level_Info_Grid / HBoxContainer / Description_Scroll / Description.speech_break = false
	else :
		toggle_menu()

func _on_Settings_Button_Pressed(m:int, button_id:TextureButton):
	goto_menu(m, SETTINGS, button_id)
	active_element = $Settings
	$Settings / GridContainer / PanelContainer6 / VBoxContainer3 / PlayTime.text = "Active Play Time:\n" + Global.time2str(Global.play_time)
	$Settings.rect_position.x = 320
	$Settings.raise()
	$Settings.come()

func level_end():
	active_element = $Level_End_Grid
	$Level_End_Grid.rect_position.x = 512
	$Level_End_Grid.come()
	$Level_End_Grid.set_performance_info()
	menu[START].hide()

func _on_Quit_Button_Pressed(m:int, button_id:TextureButton):
	get_tree().quit()

func _on_Weapon_1_Pressed(m:int, button_id:TextureButton):
	current_weapon_select = 1
	goto_menu(m, WEAPON_SELECT, button_id)
	button_state()

func _on_Weapon_2_Pressed(m:int, button_id:TextureButton):
	current_weapon_select = 2
	goto_menu(m, WEAPON_SELECT, button_id)
	button_state()


func _on_Rod_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_ROD)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(BUTTON_TEXTURES[B_W_ROD])

func _on_SKS_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_SKS)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(BUTTON_TEXTURES[B_W_SKS])

func _on_Nailer_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_NAILER)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(BUTTON_TEXTURES[B_W_NAILER])

func _on_DNA_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_CANCER)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(BUTTON_TEXTURES[B_W_CANCER])
func _on_Pistol_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_PISTOL)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(BUTTON_TEXTURES[B_W_PISTOL])
func _on_SMG_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_SMG)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_S_SMG_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_S_SMG)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_Shotgun_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_SHOTGUN)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_Shock_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_SHOCK)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_RL_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_RL)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_Sniper_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_SNIPER)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_Steyr_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_STEYR)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_AR_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_AR)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_AN94_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_AN94)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_MKR_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_MKR)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_Nambu_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_NAMBU)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_Gas_Launcher_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_GAS_LAUNCHER)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_MG3_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_MG3)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_Autoshotgun_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_AUTOSHOTGUN)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_Mauser_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_MAUSER)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_Bore_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_BORE)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_Radgun_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_RADIATOR)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_Tranq_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_TRANQ)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_Blackjack_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_BLACKJACK)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_Flashlight_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_FLASHLIGHT)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_Zippy_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_ZIPPY)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_VAG72_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_VAG72)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_FT_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_FLAMETHROWER)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)
func _on_Light_Pressed(m:int, button_id:TextureButton):
	set_weapon(W_LIGHT)
	go_back(m, button_id)
	weapon_select_buttons[current_weapon_select - 1].set_normal_texture(button_id.texture_normal)

func set_weapon(w_index:int):
	match current_weapon_select:
		1:
			$Weapon1_Viewport.get_node("Weapon").MESH[weapon_1].hide()
			weapon_1 = w_index
			$Weapon1_Viewport.get_node("Weapon").MESH[weapon_1].show()
		2:
			$Weapon2_Viewport.get_node("Weapon").MESH[weapon_2].hide()
			weapon_2 = w_index
			$Weapon2_Viewport.get_node("Weapon").MESH[weapon_2].show()
	for w in range(Global.CURRENT_WEAPONS.size()):
		if w == weapon_1 or w == weapon_2:
			Global.CURRENT_WEAPONS[w] = true
		else :
			Global.CURRENT_WEAPONS[w] = false

func _on_Return_Button_Pressed(m:int, button_id:TextureButton):
	if menu_changing:
		return 
	go_back(m, button_id)
	
	get_tree().get_nodes_in_group("MultiplayerMenu")[0].disable_menu()
	
	if menu[m] == menu[LEVEL_SELECT]:
		$Level_Info_Grid / HBoxContainer / Description_Scroll / Description.speech_break = true

func _on_Mission_Start_Pressed(m:int, button_id:TextureButton):
	if Multiplayer.game_init(Global.LEVELS[Global.CURRENT_LEVEL]):
		Global.STOCKS.save_stocks("user://stocks.save")
		goto_menu(m, START, button_id)
		toggle_menu()
		show_buttons(menu[START], 2, 4)
		$Hover_Panel.hide()
		in_game = true
		if weapon_1 <= 3 and weapon_2 <= 3:
			Global.stock_mode = true
		else :
			Global.stock_mode = false
		print(Global.stock_mode)
		$Level_Info_Grid / HBoxContainer / Description_Scroll / Description.speech_break = true

func _on_Level_Pressed(m:int, button_id:TextureButton):
	
	var level_index = button_id.get_index() - 6
	Global.CURRENT_LEVEL = level_index
	if Global.LEVEL_PUNISHED[Global.CURRENT_LEVEL]:
		$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / Punishment_Image.modulate = Color(1, 1, 1, 1)
	else :
		$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / Punishment_Image.modulate = Color(0.7, 0, 0, 1)
	update_level_info()
	for button in range(level_buttons.size()):
		if button == Global.CURRENT_LEVEL:
			level_buttons[button].disabled = true
		else :
			level_buttons[button].disabled = false
		if button > Global.L_PUNISHMENT:
			if Global.BONUS_UNLOCK.find(Global.BONUS_LEVELS[button - Global.L_PUNISHMENT - 1]) != - 1 and button != Global.CURRENT_LEVEL:
				level_buttons[button].show()
				level_buttons[button].texture_disabled = BUTTON_TEXTURES_D[0]
				level_buttons[button].disabled = false
			else :
				level_buttons[button].show()
				if Global.BONUS_UNLOCK.find(Global.BONUS_LEVELS[button - Global.L_PUNISHMENT - 1]) != - 1:
					level_buttons[button].texture_disabled = BUTTON_TEXTURES_D[0]
				else :
					level_buttons[button].texture_disabled = MYSTERY
				level_buttons[button].disabled = true

	$Level_Info_Grid / HBoxContainer / Description_Scroll / Description.visible_characters = 0


	$Level_Info_Grid / HBoxContainer / Description_Scroll / Description.speech()

	

func go_back(m:int, b_id:TextureButton):
	
	Global.STOCKS.save_stocks("user://stocks.save")
	var counter = 0
	menu_changing = true
	for child in active_menus[active_menus.size() - 1].get_children():
		child.disabled = true
	if active_element != null:
		if (active_menus[active_menus.size() - 1] != menu[WEAPON_SELECT]):
			active_element.go()
		if active_element == $Character_Menu or active_element == $Stock_Menu:
			active_element = $Level_Info_Grid
	b_position = b_id.rect_position
	for child in range(active_menus[active_menus.size() - 1].get_children().size() - 1, - 1, - 1):
		counter += 1
		if fmod(counter, 2) - 1 == 0:
			$SFX / Close.pitch_scale = 1 + rand_range( - 0.3, 0.3)
			$SFX / Close.play()
		var to_pos = b_position
		
		while ( not active_menus[active_menus.size() - 1].get_children()[child].rect_position.is_equal_approx(to_pos)):
			active_menus[active_menus.size() - 1].get_children()[child].set_position(lerp(active_menus[active_menus.size() - 1].get_children()[child].rect_position, to_pos, 1))
			hover_info.get_parent().hide()
			yield (get_tree(), "idle_frame")
		active_menus[active_menus.size() - 1].get_children()[child].hide()
	
	for child in active_menus[active_menus.size() - 2].get_children():
		child.disabled = false
	
	active_menus.pop_back()
	button_state()
	hover_info.get_parent().hide()
	menu_changing = false









	

func goto_menu(from_menu:int, to_menu:int, b:TextureButton):
	Global.STOCKS.save_stocks("user://stocks.save")
	if Global.LEVEL_PUNISHED[Global.CURRENT_LEVEL]:
		$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / Punishment_Image.modulate = Color(1, 1, 1, 1)
	else :
		$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / Punishment_Image.modulate = Color(0.7, 0, 0, 1)
	menu_changing = true
	if active_menus.find(menu[to_menu]) != - 1 and active_menus.size() > 1:
		
		for m in active_menus:
			if m != menu[to_menu]:
				for child in m.get_children():
					child.hide()
					child.disabled = true
					child.set_position(m.get_children()[0].rect_position)
			else :
				for child in m.get_children():
					child.disabled = false
		active_menus.pop_back()
		active_element.go()
		menu_changing = false
		return 
	active_menus.append(menu[to_menu])
	
	b_position = b.rect_position
	
	var wep_dir = 1
	for child in menu[from_menu].get_children():
		child.disabled = true
	for child in menu[to_menu].get_children():
		child.disabled = true
		if fmod(menu[to_menu].get_children().find(child), 3) == 0:
			$SFX / Open.pitch_scale = 0.43 + rand_range( - 0.3, 0.1)
			$SFX / Open.play()
		
		child.rect_size = button_size
		dir = menu_dir[from_menu]
		if menu[to_menu].get_children().find(child) >= 5:
			
			
			
			
				dir = (dir + 2) % 3
		if to_menu == LEVEL_SELECT:
			dir = level_select_dir[menu[to_menu].get_children().find(child)]
		if to_menu == WEAPON_SELECT:
			dir = wep_dir
			if menu[to_menu].get_children().find(child) == 6:
				dir = 2
				wep_dir = 3
			if menu[to_menu].get_children().find(child) == 12:
				dir = 2
				wep_dir = 1
			if menu[to_menu].get_children().find(child) == 18:
				dir = 2
				wep_dir = 3
			if menu[to_menu].get_children().find(child) == 24:
				dir = 2
				wep_dir = 1
		
		
		
		
		
		
		match dir:
			UP:
				b_position.y -= button_size.y
			RIGHT:
				b_position.x += button_size.x
				
			DOWN:
				b_position.y += button_size.y
			LEFT:
				b_position.x -= button_size.x
				
		child.show()
		var to_pos = b_position
		button_state()
		while ( not child.rect_position.is_equal_approx(to_pos)):
			child.disabled = true
			child.set_position(lerp(child.rect_position, to_pos, 1))
			
			yield (get_tree(), "idle_frame")
		child.disabled = false
		button_state()
		
		update_level_info()
	menu_changing = false

func _input(event):
	if menu_changing:
		return 
	if Global.cutscene:
		return 
	if (event is InputEventMouseButton or event is InputEventKey) and event.is_pressed() and wait_for_key:
		key_pressed = event
		wait_for_key = false
	if event is InputEventMouseButton and not in_game:
		if event.pressed and not visible:
			toggle_menu()
			return 
	if event is InputEventKey:
		if event.pressed and not visible and not in_game:
			toggle_menu()
			return 
		if Input.is_action_just_pressed("ui_cancel"):
			if in_game:
				if is_instance_valid(Global.player):
					if Global.player.died:
						return 
			if (active_menus.size() != 1):
				if active_menus.size() > 0:
					
						
					if active_element != $Character_Menu:
						$Level_Info_Grid / HBoxContainer / Description_Scroll / Description.speech_break = true
					go_back(active_menus.size() - 1, active_menus[active_menus.size() - 1].get_children()[0])
			else :
				toggle_menu()

func button_state():
	if active_menus.size() <= 0:
		return 
	if active_menus[active_menus.size() - 1] == menu[LEVEL_SELECT]:
		for button in range(level_buttons.size()):
			if button <= Global.LEVELS_UNLOCKED:
				level_buttons[button].show()
			else :
				level_buttons[button].hide()

			if button == Global.CURRENT_LEVEL:
				level_buttons[button].disabled = true
			else :
				level_buttons[button].disabled = false
			if button > Global.L_PUNISHMENT:
				if Global.BONUS_UNLOCK.find(Global.BONUS_LEVELS[button - Global.L_PUNISHMENT - 1]) != - 1 and button != Global.CURRENT_LEVEL:
					level_buttons[button].show()
					level_buttons[button].disabled = false
				elif button:
					level_buttons[button].show()
					if Global.BONUS_UNLOCK.find(Global.BONUS_LEVELS[button - Global.L_PUNISHMENT - 1]) != - 1:
						level_buttons[button].texture_disabled = BUTTON_TEXTURES_D[0]
					else :
						level_buttons[button].texture_disabled = MYSTERY
					level_buttons[button].disabled = true
	if active_menus[active_menus.size() - 1] == menu[WEAPON_SELECT]:
		for button in range(0, Global.WEAPONS_UNLOCKED.size()):
			if Global.WEAPONS_UNLOCKED[button] and not Global.CURRENT_WEAPONS[button]:
				menu[WEAPON_SELECT].get_children()[button + 1].disabled = false
			else :
				
				menu[WEAPON_SELECT].get_children()[button + 1].disabled = true
	


func _on_Resolution_List_item_activated(index):
	var full = false
	if Global.full_screen:
		full = true
		_on_Full_Screen_toggled(false)
	OS.set_window_size(RESOLUTIONS[index])
	Global.resolution = [RESOLUTIONS[index].x, RESOLUTIONS[index].y]
	OS.set_window_position(OS.get_screen_size() * 0.5 - OS.window_size * 0.5)
	OS.window_position.y = clamp(OS.window_position.y, 0, 30000)
	OS.window_position.x = clamp(OS.window_position.y, 0, 30000)
	rect_scale.x = Global.resolution[0] / 1280
	rect_scale.y = Global.resolution[1] / 720
	if full:
		_on_Full_Screen_toggled(true)
	
	

func _set_res(x, y):
	OS.set_window_size(Vector2(x, y))
	Global.resolution = [x, y]
	OS.set_window_position(Vector2(0, 0))
	
	rect_scale.x = x / 1280
	rect_scale.y = y / 720

func set_res(x, y):
	var full = false
	if Global.full_screen:
		full = true
		_on_Full_Screen_toggled(false)
	OS.set_window_size(Vector2(x, y))
	Global.resolution = [x, y]
	OS.set_window_position(OS.get_screen_size() * 0.5 - OS.window_size * 0.5)
	OS.window_position.y = clamp(OS.window_position.y, 0, 30000)
	OS.window_position.x = clamp(OS.window_position.y, 0, 30000)
	rect_scale.x = Global.resolution[0] / 1280
	rect_scale.y = Global.resolution[1] / 720
	if full:
		_on_Full_Screen_toggled(true)


func update_level_info()->void :
	var meta_file = File.new()
	if not meta_file.file_exists(Global.LEVEL_META[Global.CURRENT_LEVEL]):
		return 
	meta_file.open(Global.LEVEL_META[Global.CURRENT_LEVEL], File.READ)
	var parsed_level_meta:Dictionary = {}
	parsed_level_meta = parse_json(meta_file.get_as_text())
	var level_name = parsed_level_meta.get("name")
	var objectives = parsed_level_meta.get("objectives")
	var description = parsed_level_meta.get("description")
	var level_info = $Level_Info_Grid / HBoxContainer / Description_Scroll / Description
	
	level_info.text = ""
	$Level_Info_Grid / HBoxContainer / VBoxContainer / Objective_Panel / Objectives.text = ""
	for objective in objectives:
		$Level_Info_Grid / HBoxContainer / VBoxContainer / Objective_Panel / Objectives.text += objective + "\n"
	if Global.hope_discarded:
		$Level_Info_Grid / HBoxContainer / VBoxContainer / Objective_Panel / Objectives.text += "???"
	level_info.text += description
	var level_time = $Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / Best_Time
	var level_stime = $Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / Best_STime
	var level_hell_time = $Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / Best_Hell_Time
	var level_hell_stime = $Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / Best_Hell_STime
	if Global.ending_3:
		$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / Chaos_Mode.show()
	else :
		$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / Chaos_Mode.hide()
	if not Global.hell_discovered:
		$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellRank_Image.hide()
		$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellSRank_Image.hide()
		level_hell_time.hide()
		level_hell_stime.hide()
		
	else :
		$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellRank_Image.show()
		$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellSRank_Image.show()
		level_hell_time.show()
		level_hell_stime.show()
	if Global.LEVEL_TIMES[Global.CURRENT_LEVEL] != null:
		level_time.text = Global.LEVEL_TIMES[Global.CURRENT_LEVEL]
		level_stime.text = Global.LEVEL_STIMES[Global.CURRENT_LEVEL]
		if Global.LEVEL_TIMES_RAW[Global.CURRENT_LEVEL] < Global.LEVEL_RANK_S[Global.CURRENT_LEVEL]:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / Rank_Image.texture = RANK_LETTERS[3]
		elif Global.LEVEL_TIMES_RAW[Global.CURRENT_LEVEL] < Global.LEVEL_RANK_A[Global.CURRENT_LEVEL]:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / Rank_Image.texture = RANK_LETTERS[2]
		elif Global.LEVEL_TIMES_RAW[Global.CURRENT_LEVEL] < Global.LEVEL_RANK_B[Global.CURRENT_LEVEL]:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / Rank_Image.texture = RANK_LETTERS[1]
		elif Global.LEVEL_TIMES_RAW[Global.CURRENT_LEVEL] != 99999999:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / Rank_Image.texture = RANK_LETTERS[0]
		else :
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / Rank_Image.texture = RANK_LETTERS[4]

	if Global.HELL_TIMES[Global.CURRENT_LEVEL] != null:
		level_hell_time.text = Global.HELL_TIMES[Global.CURRENT_LEVEL]
		if Global.HELL_TIMES_RAW[Global.CURRENT_LEVEL] < Global.HELL_RANK_S[Global.CURRENT_LEVEL]:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellRank_Image.texture = RANK_LETTERS[3]
		elif Global.HELL_TIMES_RAW[Global.CURRENT_LEVEL] < Global.HELL_RANK_A[Global.CURRENT_LEVEL]:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellRank_Image.texture = RANK_LETTERS[2]
		elif Global.HELL_TIMES_RAW[Global.CURRENT_LEVEL] < Global.HELL_RANK_B[Global.CURRENT_LEVEL]:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellRank_Image.texture = RANK_LETTERS[1]
		elif Global.HELL_TIMES_RAW[Global.CURRENT_LEVEL] != 99999999:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellRank_Image.texture = RANK_LETTERS[0]
		else :
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellRank_Image.texture = RANK_LETTERS[4]

	if Global.HELL_STIMES[Global.CURRENT_LEVEL] != null:
		level_hell_stime.text = Global.HELL_STIMES[Global.CURRENT_LEVEL]
		
			
		
		if Global.HELL_STIMES_RAW[Global.CURRENT_LEVEL] < Global.HELL_SRANK_S[Global.CURRENT_LEVEL]:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellSRank_Image.texture = RANK_LETTERS[3]
		elif Global.HELL_STIMES_RAW[Global.CURRENT_LEVEL] < Global.HELL_RANK_A[Global.CURRENT_LEVEL]:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellSRank_Image.texture = RANK_LETTERS[2]
		elif Global.HELL_STIMES_RAW[Global.CURRENT_LEVEL] < Global.HELL_RANK_B[Global.CURRENT_LEVEL]:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellSRank_Image.texture = RANK_LETTERS[1]
		elif Global.HELL_STIMES_RAW[Global.CURRENT_LEVEL] != 99999999:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellSRank_Image.texture = RANK_LETTERS[0]
		else :
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellSRank_Image.texture = RANK_LETTERS[4]


	if Global.LEVEL_STIMES[Global.CURRENT_LEVEL] != null:
		if Global.LEVEL_STIMES_RAW[Global.CURRENT_LEVEL] < Global.LEVEL_TIMES_RAW[Global.CURRENT_LEVEL]:
			level_time.text = Global.LEVEL_STIMES[Global.CURRENT_LEVEL]
		if Global.LEVEL_STIMES_RAW[Global.CURRENT_LEVEL] < Global.LEVEL_SRANK_S[Global.CURRENT_LEVEL]:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / SRank_Image.texture = RANK_LETTERS[3]
		elif Global.LEVEL_STIMES_RAW[Global.CURRENT_LEVEL] < Global.LEVEL_RANK_A[Global.CURRENT_LEVEL]:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / SRank_Image.texture = RANK_LETTERS[2]
		elif Global.LEVEL_STIMES_RAW[Global.CURRENT_LEVEL] < Global.LEVEL_RANK_B[Global.CURRENT_LEVEL]:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / SRank_Image.texture = RANK_LETTERS[1]
		elif Global.LEVEL_STIMES_RAW[Global.CURRENT_LEVEL] != 99999999:
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / SRank_Image.texture = RANK_LETTERS[0]
		else :
			$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / SRank_Image.texture = RANK_LETTERS[4]
	meta_file.close()
	$Level_Info_Grid / Level_Info_Vbox / Level_Image.texture = Global.LEVEL_IMAGES[Global.CURRENT_LEVEL]

func toggle_menu():
	if (active_menus[active_menus.size() - 1] == menu[START] and active_element != $Level_End_Grid):
		visible = not visible
		if (Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else :
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if (in_game):
			#get_tree().paused = not get_tree().paused
			pass

func _on_Master_Volume_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	Global.master_volume = value


func _on_Music_Volume_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	Global.music_volume = value


func _on_M_Sensitivity_value_changed(value):
	Global.mouse_sensitivity = value * 0.01


func _on_FOV_value_changed(value):
	Global.FOV = value
	$Settings / GridContainer / PanelContainer / VBoxContainer / FOVLABEL.text = "FOV: " + str(Global.FOV)

func _on_Character_Speak():
	$Level_Info_Grid / HBoxContainer / VBoxContainer / Portrait.texture = HANDLER_FRAMES[randi() % 3]



func _on_Full_Screen_toggled(button_pressed):
	if button_pressed:
		OS.window_borderless = true
		OS.window_fullscreen = true
		Global.full_screen = true
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(Global.resolution[0], Global.resolution[1]))
	else :
		OS.window_borderless = true
		OS.window_fullscreen = false
		Global.full_screen = false
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(Global.resolution[0], Global.resolution[1]))
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_KEEP, Vector2(Global.resolution[0], Global.resolution[1]))
		
		


func _on_Exit_Menu_Pressed(m:int, b:Button):
	$Hover_Panel.hide()
	get_node("Soul_Rended").hide()
	
	for w in range(Global.CURRENT_WEAPONS.size()):
		if w == weapon_1 or w == weapon_2:
			Global.CURRENT_WEAPONS[w] = true
		else :
			Global.CURRENT_WEAPONS[w] = false
	Global.goto_scene("res://MOD_CONTENT/CruS Online/maps/crus_online_lobby.tscn")
	in_game = false
	menu[START].show()
	#get_tree().paused = false
	active_element.hide()
	active_element.go()
	hide_buttons(menu[START], 2, 4)

func _on_Exit_Level_Select_Pressed(m:int, b:Button):
	$Hover_Panel.hide()
	get_node("Soul_Rended").hide()
	Global.objective_complete = false
	Global.objectives = 0
	for w in range(Global.CURRENT_WEAPONS.size()):
		if w == weapon_1 or w == weapon_2:
			Global.CURRENT_WEAPONS[w] = true
		else :
			Global.CURRENT_WEAPONS[w] = false
	Global.goto_scene("res://MOD_CONTENT/CruS Online/maps/crus_online_lobby.tscn")
	in_game = false
	menu[START].show()
	#get_tree().paused = false
	if active_element:
		active_element.hide()
		active_element.go()
	hide_buttons(menu[START], 2, 4)
	_on_Start_Button_Pressed(START, menu[START].get_child(0))


func _on_exls():
	_on_Exit_Level_Select_Pressed(START, menu[START].get_child(0))
	$Hover_Panel.hide()
func _on_exmm():
	_on_Exit_Menu_Pressed(START, menu[START].get_child(0))
	
func _on_rb():
	_on_Retry_Button_Pressed(START, menu[START].get_child(0))
	
func _on_qb():
	_on_Quit_Button_Pressed(START, menu[START].get_child(0))

func _on_Retry_Button_Pressed(m:int, b:TextureButton):
	if Multiplayer.game_init(Global.LEVELS[Global.CURRENT_LEVEL]):
		Global.STOCKS.save_stocks("user://stocks.save")
		$Hover_Panel.hide()
		get_node("Soul_Rended").hide()
		if active_element == $Level_End_Grid:
			active_element.hide()
			active_element = null
			if ( not Global.objective_complete and not Global.player.died) or Global.objective_complete:
				if Global.CURRENT_LEVEL < Global.L_PUNISHMENT:
					Global.CURRENT_LEVEL -= 1
			else :
				#get_tree().paused = true
				pass
		menu[START].show()
		Global.objective_complete = false
		Global.objectives = 0
		toggle_menu()
		
		for w in range(Global.CURRENT_WEAPONS.size()):
			if w == weapon_1 or w == weapon_2:
				Global.CURRENT_WEAPONS[w] = true
			else :
				Global.CURRENT_WEAPONS[w] = false

func _on_Key_List_item_activated(index):
	wait_for_key = true
	while wait_for_key:
		$Key_Popup / PanelContainer.rect_size.x = 240
		$Key_Popup / PanelContainer.rect_size.y = 240
		$Key_Popup.popup_centered(Vector2(240, 240))
		yield (get_tree(), "idle_frame")
	$Key_Popup.hide()
	match index:
		KEY_LEFT:
			set_inputs("movement_left")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Left: " + key_pressed.as_text())
		KEY_RIGHT:
			set_inputs("movement_right")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Right: " + key_pressed.as_text())
		KEY_FORWARD:
			set_inputs("movement_forward")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Forward: " + key_pressed.as_text())
		KEY_BACK:
			set_inputs("movement_backward")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Back: " + key_pressed.as_text())
		KEY_JUMP:
			set_inputs("movement_jump")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Jump: " + key_pressed.as_text())
		KEY_SHOOT:
			set_inputs("mouse_1")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Shoot: " + key_pressed.as_text())
		KEY_USE:
			set_inputs("Use")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Use: " + key_pressed.as_text())
		KEY_KICK:
			set_inputs("kick")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Kick: " + key_pressed.as_text())
		KEY_RELOAD:
			set_inputs("reload")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Reload: " + key_pressed.as_text())
		KEY_LEAN_LEFT:
			set_inputs("Lean_Left")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Lean Left: " + key_pressed.as_text())
		KEY_LEAN_RIGHT:
			set_inputs("Lean_Right")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Lean Right: " + key_pressed.as_text())
		KEY_ZOOM:
			set_inputs("zoom")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Zoom: " + key_pressed.as_text())
		KEY_WEAPON1:
			set_inputs("weapon1")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Weapon 1: " + key_pressed.as_text())
		KEY_WEAPON2:
			set_inputs("weapon2")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Weapon 2: " + key_pressed.as_text())
		KEY_LAST_WEAPON:
			set_inputs("switch_weapon")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Last Weapon: " + key_pressed.as_text())
		KEY_CROUCH:
			set_inputs("crouch")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Crouch: " + key_pressed.as_text())
		KEY_TERTIARY:
			set_inputs("Tertiary_Weapon")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Tertiary Weapon: " + key_pressed.as_text())
		KEY_THROW_WEAPON:
			set_inputs("drop")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Throw Weapon: " + key_pressed.as_text())
		KEY_SUICIDE:
			set_inputs("Suicide")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Suicide: " + key_pressed.as_text())
		KEY_STOCKS:
			set_inputs("Stocks")
			$Settings / GridContainer / PanelContainer2 / VBoxContainer4 / Key_List.set_item_text(index, "Stock Market: " + key_pressed.as_text())
func set_inputs(action):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, key_pressed)


func _on_color_value_changed(value):
	Global.blood_color = Color($Settings / GridContainer / PanelContainer4 / VBoxContainer3 / HBoxContainer / R.value, $Settings / GridContainer / PanelContainer4 / VBoxContainer3 / HBoxContainer2 / G.value, $Settings / GridContainer / PanelContainer4 / VBoxContainer3 / HBoxContainer3 / B.value, $Settings / GridContainer / PanelContainer4 / VBoxContainer3 / HBoxContainer4 / A.value)
	$Settings / GridContainer / PanelContainer4 / VBoxContainer3 / Blood_Color_Rect.color = Global.blood_color


func _on_Skip_Intro_toggled(value):
	Global.skip_intro = value


func _on_Civslider_value_changed(value):
	if value != 101:
		$Settings / GridContainer / PanelContainer6 / VBoxContainer3 / Civcount_Label.text = "Civilians: " + str(value - 1) + "%"
		Global.civilian_reduction = int(value)
	else :
		$Settings / GridContainer / PanelContainer6 / VBoxContainer3 / Civcount_Label.text = "Civilians: MAX"
		Global.civilian_reduction = int(value)
	


func _on_Drawslider_value_changed(value):
	Global.draw_distance = value
	$Settings / GridContainer / PanelContainer6 / VBoxContainer3 / Draw_Label.text = "Draw Distance:\n" + str(value)


func _on_Reflections_toggled(value):
	Global.reflections = value


func _on_InvertY_toggled(value):
	Global.invert_y = value


func _reset_level_progression():

	$ConfirmationDialog.popup(Rect2(get_global_mouse_position(), Vector2(256, 128)))
	$ConfirmationDialog.dialog_text = "Reset level progression?"
	while confirmed == false:
		yield (get_tree(), "idle_frame")
	confirmed = false
	if cancel == true:
		cancel = false
		return 
	Global.LEVELS_UNLOCKED = 1
	Global.CURRENT_LEVEL = 0
	if Global.implants.purchased_implants.find("House") != - 1:
		Global.implants.purchased_implants.remove(Global.implants.purchased_implants.find("House"))
	Global.BONUS_UNLOCK = []
	button_state()

func _on_ClearSave_pressed():
	$ConfirmationDialog.popup(Rect2(get_global_mouse_position(), Vector2(256, 128)))
	$ConfirmationDialog.dialog_text = "This will reset all of your progress. Are you sure?"
	while confirmed == false:
		yield (get_tree(), "idle_frame")
	confirmed = false
	if cancel == true:
		cancel = false
		return 
	Global.money = 0
	Global.play_time = 0
	$Settings / GridContainer / PanelContainer6 / VBoxContainer3 / PlayTime.text = "Active Play Time:\n0.0.0"
	Global.BONUS_UNLOCK = []
	Global.implants.purchased_implants = []
	$Character_Menu / Character_Container.clear_equips()
	Global.LEVEL_TIMES = []
	Global.LEVEL_TIMES_RAW = []
	Global.LEVEL_STIMES = []
	Global.LEVEL_STIMES_RAW = []
	Global.HELL_TIMES = []
	Global.HELL_TIMES_RAW = []
	Global.HELL_STIMES = []
	Global.HELL_STIMES_RAW = []
	Global.LEVEL_PUNISHED = []
	Global.DEAD_CIVS = []
	Global.ending_1 = false
	Global.ending_3 = false
	Global.hope_discarded = false
	Global.hell_discovered = false
	Global.ending_2 = false
	Global.ending_2 = false
	Global.death = false
	Global.water_material.set_shader_param("albedoTex", Global.blue_water)
	Global.character_mat.set_shader_param("albedoTex", load("res://Textures/Misc/mainguy_clothes.png"))
	$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellRank_Image.hide()
	$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / HBoxContainer / HellSRank_Image.hide()
	$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / Best_Hell_Time.hide()
	$Level_Info_Grid / Level_Info_Vbox / Time_Panel / VBoxContainer / Best_Hell_STime.hide()
	Global.set_soul()
	for level in range(Global.LEVELS.size()):
		Global.LEVEL_TIMES.append("N/A")
		Global.LEVEL_TIMES_RAW.append(99999999)
		Global.LEVEL_PUNISHED.append(false)
		Global.LEVEL_STIMES.append("N/A")
		Global.LEVEL_STIMES_RAW.append(99999999)
		Global.HELL_TIMES.append("N/A")
		Global.HELL_TIMES_RAW.append(99999999)
		Global.HELL_STIMES.append("N/A")
		Global.HELL_STIMES_RAW.append(99999999)
	for weapon in range(Global.WEAPONS_UNLOCKED.size()):
		if weapon > 3:
			Global.WEAPONS_UNLOCKED[weapon] = false
		if weapon > 1:
			Global.CURRENT_WEAPONS[weapon] = false
	current_weapon_select = 1
	set_weapon(W_PISTOL)
	current_weapon_select = 2
	set_weapon(W_SMG)
	Global.LEVELS_UNLOCKED = 1
	Global.CURRENT_LEVEL = 0
	button_state()
	for stock in Global.STOCKS.stocks:
		stock.price = stock.starting_price
		stock.trend = stock.starting_trend
		stock.owned = 0
	Global.MONEY_ITEMS = []
	Global.STOCKS.FISH_FOUND = []
	Global.STOCKS.ORGANS_FOUND = []
	Global.STOCKS.save_stocks("user://stocks.save")
	Global.save_game()


func _on_ConfirmationDialog_confirmed():
	confirmed = true
func _on_Cancel_Pressed():
	cancel = true


func _on_CameraSway_toggled(value):
	Global.camera_sway = value


func _on_Gamma_value_changed(value):
	Global.screenmat.set_shader_param("gamma", value)
	Global.gamma = value
	$Settings / GridContainer / PanelContainer / VBoxContainer / GAMMALABEL.text = "Gamma: " + str(value)


func _on_Hiperf_toggled(value):
	Global.high_performance = value
	if value:
		Engine.iterations_per_second = 15
	else :
		Engine.iterations_per_second = 30


func _on_Timer_toggled(value):
	Global.timer = value


func _on_ResetTimer_pressed():
	Global.play_time = 0
	$Settings / GridContainer / PanelContainer6 / VBoxContainer3 / PlayTime.text = "Active Play Time:\n0.0.0"
