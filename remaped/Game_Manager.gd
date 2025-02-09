extends Node

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var loader:ResourceInteractiveLoader
var wait_frames:int
var time_max:float = 100
var play_time = 0
var current_scene = null

enum {KEY_FORWARD, KEY_LEFT, KEY_RIGHT, KEY_BACK, KEY_SHOOT, KEY_JUMP, KEY_CROUCH, KEY_RELOAD, KEY_ZOOM, KEY_USE, KEY_KICK, KEY_LEAN_LEFT, KEY_LEAN_RIGHT, KEY_WEAPON1, KEY_WEAPON2, KEY_LAST_WEAPON, KEY_TERTIARY, KEY_THROW_WEAPON, KEY_SUICIDE, KEY_STOCKS}
enum {L_HQ, L_PHARMA, L_PARADISE, L_SPACE, L_ANDROGEN, L_MALL, L_APARTMENT, L_CRUISE, L_SWAMP, L_CASINO, L_CASTLE, L_OFFICE, L_PUNISHMENT}

var LEVEL_META:Array
var draw_distance = 400
var LEVEL_TIMES:Array
var LEVEL_TIMES_RAW:Array
var LEVEL_STIMES:Array
var LEVEL_STIMES_RAW:Array
var HELL_TIMES:Array
var HELL_TIMES_RAW:Array
var HELL_STIMES:Array
var HELL_STIMES_RAW:Array
var STOCKS
var timer = false
var character_mat = preload("res://Materials/mainguy.tres")
var rain = true
var objectives:int = 0
var below_30 = 0
var chaos_mode = false
var objective_complete:bool = false
var CURRENT_WEAPONS:Array
var DIALOGUE
var average_fps = 60
var DEAD_CIVS:Array
var high_performance = false
var border
var money = 0
var time = 0
var camera_sway = true
var debug = false
var reflections = true
var invert_y = false
var WEAPONS_UNLOCKED:Array
var CURRENT_LEVEL:int = 0
var LEVELS_UNLOCKED:int = 1
var t:float = 0
var player
var cutscene = false
var nav
var active_enemies = 0
var music
var soul_intact = true
var death = false
var husk_mode = false
var hell_discovered = false
var hope_discarded = false
var punishment_mode = false
var UI:Control
var blood_color = Color(1, 0, 0, 1)
var optimization_throttle = false
var mouse_sensitivity:float = 0.1
var FOV:float = 75
var gamma:float = 1.0
var master_volume:float = 0
var music_volume:float = 0
var resolution:Array = [1280, 720]
var full_screen:bool = false
var implants
var enemy_count = 0
var consecutive_deaths = 0
var enemy_count_total = 0
var ending_1 = false
var ending_2 = false
var ending_3 = false
var civ_count = 0
var civ_count_total = 0
var skip_intro = false
var min_fps = 30
var water_material
var every_2 = false
var every_55 = false
var every_4 = false
var every_5 = false
var every_20 = false
onready var backup_timer = Timer.new()
var screenmat = preload("res://Materials/screenmat.tres")
const LEVELS:Array = ["res://Levels/Training_Level.tscn", 
						"res://Levels/Level1.tscn", 
						"res://Levels/Level2.tscn", 
						"res://Levels/Level3.tscn", 
						"res://Levels/Level4.tscn", 
						"res://Levels/Level5.tscn", 
						"res://Levels/Level6.tscn", 
						"res://Levels/Level7.tscn", 
						"res://Levels/Level8.tscn", 
						"res://Levels/Level9.tscn", 
						"res://Levels/Level10.tscn", 
						"res://Levels/Level11.tscn", 
						"res://Levels/Level12.tscn", 
						"res://Levels/Bonus1.tscn", 
						"res://Levels/Bonus2.tscn", 
						"res://Levels/Bonus3.tscn", 
						"res://Levels/Bonus4.tscn", 
						"res://Levels/Bonus5.tscn", 
						"res://Levels/BonusEND.tscn", ]
var LEVEL_IMAGES = [preload("res://Levels/Training_Level.png"), 
					preload("res://Levels/Level1.png"), 
					preload("res://Levels/Level2.png"), 
					preload("res://Levels/Level3.png"), 
					preload("res://Levels/Level4.png"), 
					preload("res://Levels/Level5.png"), 
					preload("res://Levels/Level6.png"), 
					preload("res://Levels/Level7.png"), 
					preload("res://Levels/Level8.png"), 
					preload("res://Levels/Level9.png"), 
					preload("res://Levels/Level10.png"), 
					preload("res://Levels/Level11.png"), 
					preload("res://Levels/Level12.png"), 
					preload("res://Levels/Bonus1.png"), 
					preload("res://Levels/Bonus2.png"), 
					preload("res://Levels/Bonus3.png"), 
					preload("res://Levels/Bonus4.png"), 
					preload("res://Levels/Bonus5.png"), 
					preload("res://Levels/BonusEND.png"), ]
var level_ranks = ["N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N"]
var level_stock_ranks = ["N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N"]
var hell_ranks = ["N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N"]
var hell_stock_ranks = ["N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N"]
var LEVEL_REWARDS = [0, 1000, 2000, 3000, 3000, 4000, 3000, 4000, 4000, 5000, 5000, 6000, 6000, 6000, 6000, 6000, 8000, 12000, 20000]
var LEVEL_RANK_S = [0, 50000, 60000, 20000, 60000, 60000, 30000, 60000, 60000, 40000, 40000, 160000, 80000, 60000, 60000, 120000, 120000, 300000, 60000]
var LEVEL_PUNISHED:Array
var LEVEL_RANK_A = [0, 90000, 120000, 70000, 120000, 180000, 60000, 120000, 150000, 70000, 130000, 240000, 120000, 150000, 120000, 200000, 170000, 360000, 160000]
var LEVEL_RANK_B = [0, 180000, 210000, 160000, 180000, 240000, 150000, 180000, 195000, 180000, 300000, 300000, 180000, 210000, 180000, 300000, 220000, 420000, 320000]
var LEVEL_SRANK_S = [0, 50000, 60000, 25000, 60000, 60000, 30000, 60000, 60000, 40000, 40000, 160000, 80000, 60000, 60000, 120000, 120000, 320000, 60000]

var HELL_RANK_S = [0, 60000, 80000, 40000, 70000, 80000, 40000, 60000, 70000, 50000, 50000, 160000, 80000, 90000, 90000, 150000, 160000, 300000, 240000]
var HELL_RANK_A = [0, 120000, 360000, 240000, 210000, 210000, 240000, 180000, 200000, 120000, 210000, 390000, 300000, 190000, 150000, 230000, 230000, 360000, 420000]
var HELL_RANK_B = [0, 180000, 480000, 300000, 300000, 270000, 300000, 210000, 300000, 180000, 300000, 420000, 360000, 240000, 210000, 320000, 250000, 420000, 600000]
var HELL_SRANK_S = [0, 80000, 100000, 80000, 90000, 100000, 50000, 90000, 70000, 50000, 90000, 160000, 120000, 90000, 90000, 150000, 160000, 320000, 240000]
var LEVEL_SONGS = [preload("res://Sfx/Music/hqfight.ogg"), 
					preload("res://Sfx/Music/level5.ogg"), 
					preload("res://Sfx/Music/level2.ogg"), 
					preload("res://Sfx/Music/space.ogg"), 
					preload("res://Sfx/Music/level4.ogg"), 
					preload("res://Sfx/Music/harpsimall.ogg"), 
					preload("res://Sfx/Music/apartment.ogg"), 
					preload("res://Sfx/Music/ship.ogg"), 
					preload("res://Sfx/Music/swamptune.ogg"), 
					preload("res://Sfx/Music/casino.ogg"), 
					preload("res://Sfx/Music/castle.ogg"), 
					preload("res://Sfx/Music/officemachines.ogg"), 
					preload("res://Sfx/Music/punishment.ogg"), 
					preload("res://Sfx/Music/darkworld.ogg"), 
					preload("res://Sfx/Music/ship.ogg"), 
					preload("res://Sfx/Music/cave.ogg"), 
					preload("res://Sfx/Music/clubambience2.ogg"), 
					preload("res://Sfx/Music/village.ogg"), 
					preload("res://Sfx/Music/final.ogg"), ]
var LEVEL_AMBIENCE = [preload("res://Sfx/Music/hq.ogg"), 
					preload("res://Sfx/Music/title.ogg"), 
					null, 
					null, 
					null, 
					null, 
					null, 
					null, 
					null, 
					null, 
					null, 
					null, 
					null, 
					null, 
					null, 
					null, 
					null, 
					null, 
					null]
var fps = 60
var BONUS_LEVELS:Array = ["Darkworld", "Alpine Hospitality", "God", "Club", "House", "END"]
var BONUS_UNLOCK:Array
var MONEY_ITEMS:Array
onready var ambience = $Ambience
var action = 0
var action_lerp_value = 0
var BORDERS = [preload("res://Textures/UI/border.png"), 
preload("res://Textures/UI/border2.png"), 
preload("res://Textures/UI/border3.png"), 
preload("res://Textures/UI/border4.png")]
var level_time:String = ""
var level_time_raw:float = 0
var civilian_reduction = 101
onready var menu = $Menu
var stock_mode = true
var red_water = preload("res://Maps/textures/base/red_water.png")
var blue_water = preload("res://Maps/textures/base/water.png")
var toxic_water = preload("res://Maps/textures/swamp/swampwater1.png")


func time2str(t:int):
	var elapsed = (t) / 1000
	var elapsed_msecs = t
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	var milseconds = elapsed_msecs % 1000
	return str(minutes, ".", seconds, ".", milseconds)

func levels_completed():
	var c = 0
	var i = 0
	for s in LEVEL_TIMES:
		var f = false
		if s != "N/A":
			c += 1
			f = true
			print(c)
		if not f:
			if HELL_TIMES[i] != "N/A":
				c += 1
				print("HELL", c)
		i += 1
	if c >= 18:
		return true
	else :
		return false

func _enter_tree()->void :
	#Steam.steamInit()
	STOCKS = $Stocks
	player = KinematicBody.new()
	add_child(player)
	DIALOGUE = $Dialogue
	border = $BorderContainer / Border
	
	implants = $Implants
	WEAPONS_UNLOCKED = [true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
	CURRENT_WEAPONS = [true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
	LEVEL_META = ["res://Levels/Training_Level.json", 
	"res://Levels/Level1.json", 
	"res://Levels/Level2.json", 
	"res://Levels/Level3.json", 
	"res://Levels/Level4.json", 
	"res://Levels/Level5.json", 
	"res://Levels/Level6.json", 
	"res://Levels/Level7.json", 
	"res://Levels/Level8.json", 
	"res://Levels/Level9.json", 
	"res://Levels/Level10.json", 
	"res://Levels/Level11.json", 
	"res://Levels/Level12.json", 
	"res://Levels/Bonus1.json", 
	"res://Levels/Bonus2.json", 
	"res://Levels/Bonus3.json", 
	"res://Levels/Bonus4.json", 
	"res://Levels/Bonus5.json", 
	"res://Levels/BonusEND.json", ]
	
	
	for level in range(LEVELS.size()):
		LEVEL_TIMES.append("N/A")
		LEVEL_TIMES_RAW.append(99999999)
		LEVEL_STIMES.append("N/A")
		LEVEL_STIMES_RAW.append(99999999)
		HELL_TIMES.append("N/A")
		HELL_TIMES_RAW.append(99999999)
		HELL_STIMES.append("N/A")
		HELL_STIMES_RAW.append(99999999)
		LEVEL_PUNISHED.append(false)
	load_game()
	LEVELS_UNLOCKED = clamp(LEVELS_UNLOCKED, 1, 12)
	
	if WEAPONS_UNLOCKED[1]:
		CURRENT_WEAPONS[1] = true
	if levels_completed() and BONUS_UNLOCK.find("END") == - 1:
		BONUS_UNLOCK.append("END")

func set_soul():
	border.texture = BORDERS[1]
	if is_instance_valid(player) and menu.in_game:
		if hope_discarded:
			player.UI.notify("Hope manifested", Color(1, 1, 1))
		if husk_mode:
			player.UI.notify("Bodily autonomy regained", Color(1, 0.5, 0.5))
		player.UI.notify("Divine link established", Color(0.9, 0.9, 1))
	soul_intact = true
	consecutive_deaths = 0
	hope_discarded = false
	husk_mode = false
func status():
	return death
func set_hope():
	border.texture = BORDERS[3]
	hell_discovered = true
	if is_instance_valid(player) and menu.in_game:
		if husk_mode:
			player.UI.notify("Bodily autonomy regained", Color(1, 0.5, 0.5))
		if soul_intact:
			player.UI.notify("Divine link severed", Color(0, 0, 1))
		player.UI.notify("Hope eradicated", Color(0, 0, 0))
		hope_discarded = true
		soul_intact = false
		husk_mode = false
		consecutive_deaths = 0

func _backup():
	save_game("user://backup.save")
	Global.STOCKS.save_stocks("user://stock_backup.save")
func _ready()->void :
	add_child(backup_timer)
	backup_timer.one_shot = false
	backup_timer.connect("timeout", self, "_backup")
	backup_timer.start(120)
	water_material = load("res://Maps/textures/base/water.tres")
	if ending_1 and not ending_3:
		water_material.set_shader_param("albedoTex", red_water)
	if ending_3:
		water_material.set_shader_param("albedoTex", blue_water)
	if ending_2:
		character_mat.set_shader_param("albedoTex", load("res://Textures/NPC/bosssguy_clothes.png"))
	if soul_intact:
		border.texture = BORDERS[1]
	elif husk_mode:
		border.texture = BORDERS[2]
	elif hope_discarded:
		border.texture = BORDERS[3]
	else :
		border.texture = BORDERS[0]
	music = $Music
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	print(levels_completed())

func list_files_in_directory(path:String, file_type:String)->Array:
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.get_extension() == file_type:
			files.append(path + "/" + file)
	return files

func goto_scene(path:String):
	$Loading_Screen.raise()
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path:String)->void :
	loader = ResourceLoader.load_interactive(path)
	if loader == null:
		print("OOPS")
		return 
	set_process(true)

	current_scene.queue_free()

	$Loading_Screen.visible = true
	get_tree().get_root().set_disable_input(true)
	wait_frames = 1

func _process(time:float)->void :
	if loader == null:
		set_process(false)
		return 
		
	if wait_frames > 0:
		wait_frames -= 1
		return 
		
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max:
		var err = loader.poll()
		
		if err == ERR_FILE_EOF:
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif err == OK:
			update_progress()
		else :
			loader = null
			break

func update_progress()->void :
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	$Loading_Screen / CenterContainer / ProgressBar.value = progress * 100

signal scene_loaded()

func set_new_scene(scene_resource:PackedScene)->void :
	$Loading_Screen.visible = false
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)
	get_tree().get_root().set_disable_input(false)
	raise()
	emit_signal("scene_loaded")

func add_objective()->void :
	objectives += 1

func remove_objective()->void :
	objectives -= 1
	print(objectives)
	UI.notify("Target Eliminated", Color(1, 0, 0))
	$Target_Eliminated.play()
	if objectives == 0:
		objective_complete = true
		UI.notify("All Objectives Complete. Locate the exit.", Color(1, 0, 1))

func level_finished()->void :
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_volume)
	menu.get_node("Soul_Rended").hide()
	menu.get_node("Soul_Rended").rect_position.y = 128
	menu.get_node("Soul_Rended").rect_position.x = 64
	menu.get_node("Soul_Rended").rect_size.y = 420
	menu.get_node("Soul_Rended").rect_size.x = 420
	objectives = 0
	if player.dead:
		if not Global.hope_discarded:
			consecutive_deaths += 1
		if consecutive_deaths == 4:
			if money < 0:
				money = 0
			husk_mode = true
			menu.get_node("Soul_Rended").texture = load("res://Textures/Menu/Misery_Achieved.png")
			menu.get_node("Soul_Rended").show()
			border.texture = BORDERS[2]
		elif soul_intact:
			soul_intact = false
			menu.get_node("Soul_Rended").texture = load("res://Textures/Menu/Soul_Rended.png")
			menu.get_node("Soul_Rended").show()
			border.texture = BORDERS[0]
		else :
			menu.get_node("Soul_Rended").hide()
		objective_complete = false
		$Menu / Level_End_Grid.active = true
		$Menu.level_end()
		$Menu / Level_End_Grid.rect_size.x = 720
		$Menu.show()
		
		if not husk_mode:
			money -= 500
		if husk_mode:
			consecutive_deaths = 0
		save_game()
		
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return 
	consecutive_deaths = 0
	if not hope_discarded:
		if Global.stock_mode and LEVEL_STIMES_RAW[CURRENT_LEVEL] > level_time_raw:
			LEVEL_STIMES[CURRENT_LEVEL] = level_time
			LEVEL_STIMES_RAW[CURRENT_LEVEL] = level_time_raw
			if level_time_raw < LEVEL_SRANK_S[CURRENT_LEVEL]:
				level_stock_ranks[CURRENT_LEVEL] = "S"
			elif level_time_raw < LEVEL_RANK_A[CURRENT_LEVEL]:
				level_stock_ranks[CURRENT_LEVEL] = "A"
			elif level_time_raw < LEVEL_RANK_B[CURRENT_LEVEL]:
				level_stock_ranks[CURRENT_LEVEL] = "B"
			else :
				level_stock_ranks[CURRENT_LEVEL] = "C"
		
		if LEVEL_TIMES_RAW[CURRENT_LEVEL] > level_time_raw:
			LEVEL_TIMES[CURRENT_LEVEL] = level_time
			LEVEL_TIMES_RAW[CURRENT_LEVEL] = level_time_raw
			if level_time_raw < LEVEL_RANK_S[CURRENT_LEVEL]:
				level_ranks[CURRENT_LEVEL] = "S"
			elif level_time_raw < LEVEL_RANK_A[CURRENT_LEVEL]:
				level_ranks[CURRENT_LEVEL] = "A"
			elif level_time_raw < LEVEL_RANK_B[CURRENT_LEVEL]:
				level_ranks[CURRENT_LEVEL] = "B"
			else :
				level_ranks[CURRENT_LEVEL] = "C"
	else :
		if Global.stock_mode and HELL_STIMES_RAW[CURRENT_LEVEL] > level_time_raw:
			HELL_STIMES[CURRENT_LEVEL] = level_time
			HELL_STIMES_RAW[CURRENT_LEVEL] = level_time_raw
			if level_time_raw < HELL_SRANK_S[CURRENT_LEVEL]:
				hell_stock_ranks[CURRENT_LEVEL] = "S"
			elif level_time_raw < HELL_RANK_A[CURRENT_LEVEL]:
				hell_stock_ranks[CURRENT_LEVEL] = "A"
			elif level_time_raw < HELL_RANK_B[CURRENT_LEVEL]:
				hell_stock_ranks[CURRENT_LEVEL] = "B"
			else :
				hell_stock_ranks[CURRENT_LEVEL] = "C"
		
		if HELL_TIMES_RAW[CURRENT_LEVEL] > level_time_raw:
			HELL_TIMES[CURRENT_LEVEL] = level_time
			HELL_TIMES_RAW[CURRENT_LEVEL] = level_time_raw
			if level_time_raw < HELL_RANK_S[CURRENT_LEVEL]:
				hell_ranks[CURRENT_LEVEL] = "S"
			elif level_time_raw < HELL_RANK_A[CURRENT_LEVEL]:
				hell_ranks[CURRENT_LEVEL] = "A"
			elif level_time_raw < HELL_RANK_B[CURRENT_LEVEL]:
				hell_ranks[CURRENT_LEVEL] = "B"
			else :
				hell_ranks[CURRENT_LEVEL] = "C"
	if CURRENT_LEVEL + 1 > LEVELS_UNLOCKED and CURRENT_LEVEL + 1 <= L_PUNISHMENT:
		LEVELS_UNLOCKED = CURRENT_LEVEL + 1
		LEVELS_UNLOCKED = clamp(LEVELS_UNLOCKED, 1, 12)
	if CURRENT_LEVEL == L_PUNISHMENT:
		ending_1 = true
		water_material.set_shader_param("albedoTex", red_water)
	
	




	if player.weapon.weapon1 != null:
		if not WEAPONS_UNLOCKED[player.weapon.weapon1]:
			WEAPONS_UNLOCKED[player.weapon.weapon1] = true
	if player.weapon.weapon2 != null:
		if not WEAPONS_UNLOCKED[player.weapon.weapon2]:
			WEAPONS_UNLOCKED[player.weapon.weapon2] = true
	if punishment_mode:
		money += LEVEL_REWARDS[CURRENT_LEVEL] * 2
	else :
		money += LEVEL_REWARDS[CURRENT_LEVEL]
	if punishment_mode:
		if not LEVEL_PUNISHED[CURRENT_LEVEL] and not hope_discarded:
			set_soul()
		LEVEL_PUNISHED[CURRENT_LEVEL] = true
	if levels_completed() and BONUS_UNLOCK.find("END") == - 1:
		BONUS_UNLOCK.append("END")
	save_game()
	get_tree().paused = true
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Global.CURRENT_LEVEL != Global.L_PUNISHMENT and Global.CURRENT_LEVEL != L_HQ and CURRENT_LEVEL != 18:
		$Menu / Level_End_Grid.active = true
		$Menu.level_end()
		$Menu / Level_End_Grid.rect_size.x = 720
		$Menu / Level_End_Grid / Performance_Hbox / Performance_Scroll / Performance_Vbox / Time_Label.text = "Time:" + level_time
		$Menu.show()
		if Global.CURRENT_LEVEL < Global.L_PUNISHMENT and Global.CURRENT_LEVEL != L_HQ:
			Global.CURRENT_LEVEL += 1
	else :
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		menu.hide_buttons(menu.menu[menu.START], 2, 4)
		$Menu.hide()
		menu.in_game = false
		if Global.CURRENT_LEVEL == Global.L_PUNISHMENT:
			
			goto_scene("res://Cutscenes/CutsceneEnd1.tscn")
		elif CURRENT_LEVEL == L_HQ:
			ending_2 = true
			save_game()
			character_mat.set_shader_param("albedoTex", load("res://Textures/NPC/bosssguy_clothes.png"))
			goto_scene("res://Cutscenes/CutsceneEnd2.tscn")
		elif CURRENT_LEVEL == 18:
			ending_3 = true
			save_game()
			goto_scene("res://Cutscenes/CutsceneEnd3.tscn")

func level_start()->void :
	objective_complete = false
	objectives = 0
	enemy_count = 0
	civ_count = 0

	$Menu / Level_End_Menu / HBoxContainer / VBoxContainer / Level_End_Info / Civ_HBOX2 / Civ_Value.text = "0/0"
	$Menu / Level_End_Menu / HBoxContainer / VBoxContainer / Level_End_Info / Civ_HBOX2 / Civ_Value.add_color_override("font_color", Color(1, 0, 0))
	$Menu / Level_End_Menu / HBoxContainer / VBoxContainer / Level_End_Info / Enemy_HBOX / Enemies_Value.text = "0/0"
	$Menu / Level_End_Menu / HBoxContainer / VBoxContainer / Level_End_Info / Enemy_HBOX / Enemies_Value.add_color_override("font_color", Color(1, 0, 0))
	$Menu / Level_End_Menu / HBoxContainer / VBoxContainer / VBoxContainer / .hide()


func set_current_weapon(weapon_index:int)->void :
	CURRENT_WEAPONS[weapon_index] = true
func get_current_weapon(weapon_index:int)->int:
	return CURRENT_WEAPONS[weapon_index]


func _physics_process(delta):
	time += 1
	fps = Engine.get_frames_per_second()
	if fmod(time, 2) == 0:
		every_2 = true

	else :
		every_2 = false
	if fmod(time, 55) == 0:
		every_55 = true
	else :
		every_55 = false
	if fmod(time, 5) == 0:
		every_5 = true
	else :
		every_5 = false
	if fmod(time, 4) == 0:
		every_4 = true

	else :
		every_4 = false
	
	if fmod(time, 20) == 0:
		every_20 = true
	else :
		every_20 = false
	action = lerp(action, action_lerp_value, 5 * delta)
	action_lerp_value = lerp(action_lerp_value, 0, delta * 0.1)
	action = clamp(action, 0, 72)
	if LEVEL_AMBIENCE[CURRENT_LEVEL] != null and menu.in_game:
		ambience.volume_db = music_volume - action
		music.volume_db = music_volume - 72 + action
	else :
		music.volume_db = 0
		ambience.volume_db = - 80

func save()->Dictionary:
	var save_dict = {
		"weapons_unlocked":WEAPONS_UNLOCKED, 
		"levels_unlocked":LEVELS_UNLOCKED, 
		"levels_punished":LEVEL_PUNISHED, 
		"bonus_unlocked":BONUS_UNLOCK, 
		"implants_unlocked":implants.purchased_implants, 
		"items_found":MONEY_ITEMS, 
		"soul":soul_intact, 
		"husk":husk_mode, 
		"hope":hope_discarded, 
		"consecutive_deaths":consecutive_deaths, 
		"money":money, 
		"dead_npcs":DEAD_CIVS, 
		"ending_1":ending_1, 
		"ending_2":ending_2, 
		"ending_3":ending_3, 
		"hell_discovered":hell_discovered, 
		"death":death, 
		"play_time":play_time
	}
	for level in range(LEVELS.size()):
		var meta_file = File.new()
		meta_file.open(LEVEL_META[level], File.READ)
		var parsed_level_meta:Dictionary = {}
		parsed_level_meta = parse_json(meta_file.get_as_text())
		var level_name = parsed_level_meta.get("name")
		save_dict[level_name + "_raw_time"] = LEVEL_TIMES_RAW[level]
		save_dict[level_name + "_string_stime"] = LEVEL_STIMES[level]
		save_dict[level_name + "_raw_stime"] = LEVEL_STIMES_RAW[level]
		save_dict[level_name + "_string_time"] = LEVEL_TIMES[level]
		save_dict[level_name + "_hell_raw_time"] = HELL_TIMES_RAW[level]
		save_dict[level_name + "_hell_string_stime"] = HELL_STIMES[level]
		save_dict[level_name + "_hell_raw_stime"] = HELL_STIMES_RAW[level]
		save_dict[level_name + "_hell_string_time"] = HELL_TIMES[level]
		meta_file.close()
	return save_dict



func settings()->Dictionary:
	var settings_dict = {
		"full_screen":full_screen, 
		"resolution":resolution, 
		"draw_distance":draw_distance, 
		"FOV":FOV, 
		"gamma":gamma, 
		"camera_sway":camera_sway, 
		"InvertY":invert_y, 
		"mouse_sensitivity":mouse_sensitivity, 
		"master_volume":master_volume, 
		"music_volume":music_volume, 
		"keybinds":$Menu.get_scancodes(), 
		"skip_intro":skip_intro, 
		"reflections":reflections, 
		"blood_color":[blood_color.r, blood_color.g, blood_color.b, blood_color.a], 
		"civilians":civilian_reduction, 
		"high_performance":high_performance, 
		"timer":timer
	}

	return settings_dict

func save_settings()->void :
	var settings = File.new()
	settings.open("user://settings.save", File.WRITE)
	settings.store_line(to_json(settings()))
	settings.close()

func save_game(path = "user://savegame.save")->void :
	var save_game = File.new()
	save_game.open(path, File.WRITE)
	save_game.store_line(to_json(save()))
	save_game.close()

func load_game()->void :
	var save_game = File.new()
	var settings = File.new()
	if not save_game.file_exists("user://savegame.save"):
		save_game()
	if not settings.file_exists("user://settings.save"):
		save_settings()
	
	
	
	

	
	

	save_game.open("user://savegame.save", File.READ)
	if save_game.get_len() < 2:
		save_game.close()
		if not save_game.file_exists("user://backup.save"):
			save_game()
			save_game.open("user://savegame.save", File.READ)
		else :
			save_game.open("user://backup.save", File.READ)
			if save_game.get_len() < 2:
				save_game.close()
				save_game()
				save_game.open("user://savegame.save", File.READ)
	var parsedJSON:Dictionary = {}
	parsedJSON = parse_json(save_game.get_line())
	var new_weapons_unlocked = parsedJSON.get("weapons_unlocked")
	var new_levels_unlocked = parsedJSON.get("levels_unlocked")
	var new_implants_unlocked = parsedJSON.get("implants_unlocked")
	var new_levels_punished = parsedJSON.get("levels_punished")
	var bonus_levels_unlocked = parsedJSON.get("bonus_unlocked")
	var dead_npcs = parsedJSON.get("dead_npcs")
	var items_found = parsedJSON.get("items_found")
	var p_time = parsedJSON.get("play_time")
	if p_time != null:
		play_time = p_time
	
	if items_found:
		MONEY_ITEMS = items_found
	if dead_npcs:
		DEAD_CIVS = dead_npcs
	if bonus_levels_unlocked:
		BONUS_UNLOCK = bonus_levels_unlocked
	var soul = parsedJSON.get("soul")
	var hope = parsedJSON.get("hope")
	var hell = parsedJSON.get("hell_discovered")
	var ending1 = parsedJSON.get("ending_1")
	var end2 = parsedJSON.get("ending_2")
	if end2 != null:
		ending_2 = end2
	var end3 = parsedJSON.get("ending_3")
	if end3 != null:
		ending_3 = end3
	var dth = parsedJSON.get("death")
	if ending1 != null:
		ending_1 = ending1
	if soul != null:
		soul_intact = soul
	if hope != null:
		hope_discarded = hope
	if hell != null:
		hell_discovered = hell
	if dth != null:
		death = dth
	var new_money = parsedJSON.get("money")
	if new_weapons_unlocked.size() < WEAPONS_UNLOCKED.size():
		var size_difference = WEAPONS_UNLOCKED.size() - new_weapons_unlocked.size()
		for weapon in range(size_difference):
			new_weapons_unlocked.append(false)
	if not new_money:
		new_money = 0
	var cdeaths = parsedJSON.get("consecutive_deaths")
	if cdeaths:
		consecutive_deaths = cdeaths
	var husk = parsedJSON.get("husk")
	if husk != null:
		husk_mode = husk
	money = new_money
	if not new_implants_unlocked:
		new_implants_unlocked = implants.purchased_implants
	if not new_levels_punished:
		new_levels_punished = LEVEL_PUNISHED
	if new_levels_punished.size() < LEVEL_PUNISHED.size():
		var size_difference = LEVEL_PUNISHED.size() - new_levels_punished.size()
		for i in range(size_difference):
			new_levels_punished.append(false)
	LEVEL_PUNISHED = new_levels_punished
	
	
	
	
	if new_implants_unlocked:
		implants.purchased_implants = new_implants_unlocked
	if new_weapons_unlocked:
		WEAPONS_UNLOCKED = new_weapons_unlocked
	if new_levels_unlocked:
		LEVELS_UNLOCKED = new_levels_unlocked
	else :
		LEVELS_UNLOCKED = 1
	for level in range(LEVELS.size()):
		var meta_file = File.new()
		if LEVEL_META[level] != null:
			meta_file.open(LEVEL_META[level], File.READ)

		var parsed_meta = parse_json(meta_file.get_as_text())
		var level_name = parsed_meta.get("name")
		if parsedJSON.get(level_name + "_string_time"):
			LEVEL_TIMES[level] = parsedJSON.get(level_name + "_string_time")
		if parsedJSON.get(level_name + "_raw_time"):
			LEVEL_TIMES_RAW[level] = parsedJSON.get(level_name + "_raw_time")
		if LEVEL_TIMES_RAW[level]:
			if LEVEL_TIMES_RAW[level] < LEVEL_RANK_S[level]:
				level_ranks[level] = "S"
			elif LEVEL_TIMES_RAW[level] < LEVEL_RANK_A[level]:
				level_ranks[level] = "A"
			elif LEVEL_TIMES_RAW[level] < LEVEL_RANK_B[level]:
				level_ranks[level] = "B"
			else :
				level_ranks[level] = "C"
		
		if parsedJSON.get(level_name + "_string_stime"):
			LEVEL_STIMES[level] = parsedJSON.get(level_name + "_string_stime")
		if parsedJSON.get(level_name + "_raw_stime"):
			LEVEL_STIMES_RAW[level] = parsedJSON.get(level_name + "_raw_stime")
		if LEVEL_STIMES_RAW[level]:
			if LEVEL_STIMES_RAW[level] < LEVEL_SRANK_S[level]:
				level_stock_ranks[level] = "S"
			elif LEVEL_STIMES_RAW[level] < LEVEL_RANK_A[level]:
				level_stock_ranks[level] = "A"
			elif LEVEL_STIMES_RAW[level] < LEVEL_RANK_B[level]:
				level_stock_ranks[level] = "B"
			else :
				level_stock_ranks[level] = "C"

		if parsedJSON.get(level_name + "_hell_string_time"):
			HELL_TIMES[level] = parsedJSON.get(level_name + "_hell_string_time")
		if parsedJSON.get(level_name + "_hell_raw_time"):
			HELL_TIMES_RAW[level] = parsedJSON.get(level_name + "_hell_raw_time")
		if HELL_TIMES_RAW[level]:
			if HELL_TIMES_RAW[level] < HELL_RANK_S[level]:
				hell_ranks[level] = "S"
			elif HELL_TIMES_RAW[level] < HELL_RANK_A[level]:
				hell_ranks[level] = "A"
			elif HELL_TIMES_RAW[level] < HELL_RANK_B[level]:
				hell_ranks[level] = "B"
			else :
				hell_ranks[level] = "C"
		
		if parsedJSON.get(level_name + "_hell_string_stime"):
			HELL_STIMES[level] = parsedJSON.get(level_name + "_hell_string_stime")
		if parsedJSON.get(level_name + "_hell_raw_stime"):
			HELL_STIMES_RAW[level] = parsedJSON.get(level_name + "_hell_raw_stime")
		if HELL_STIMES_RAW[level]:
			if HELL_STIMES_RAW[level] < HELL_SRANK_S[level]:
				hell_stock_ranks[level] = "S"
			elif HELL_STIMES_RAW[level] < HELL_RANK_A[level]:
				hell_stock_ranks[level] = "A"
			elif HELL_STIMES_RAW[level] < HELL_RANK_B[level]:
				hell_stock_ranks[level] = "B"
			else :
				hell_stock_ranks[level] = "C"




	save_game.close()
	
	settings.open("user://settings.save", File.READ)
	if settings.get_len() < 2:
		settings.close()
		save_settings()
		return 
	parsedJSON = parse_json(settings.get_line())
	mouse_sensitivity = parsedJSON.get("mouse_sensitivity")
	master_volume = parsedJSON.get("master_volume")
	music_volume = parsedJSON.get("music_volume")
	resolution = parsedJSON.get("resolution")
	invert_y = parsedJSON.get("InvertY")
	var tmr = parsedJSON.get("timer")
	if tmr != null:
		timer = tmr
	var hiperf = parsedJSON.get("high_performance")
	if hiperf != null:
		high_performance = hiperf
		if high_performance:
			Engine.iterations_per_second = 15
		else :
			Engine.iterations_per_second = 30
	if parsedJSON.get("gamma") != null:
		gamma = parsedJSON.get("gamma")
	if parsedJSON.get("camera_sway") != null:
		camera_sway = parsedJSON.get("camera_sway")
	
	var f_screen = parsedJSON.get("full_screen")
	if f_screen != null:
		full_screen = f_screen
	var ref = parsedJSON.get("reflections")
	if ref != null:
		reflections = ref
	var dd = parsedJSON.get("draw_distance")
	if dd:
		draw_distance = dd
	var blood_array = parsedJSON.get("blood_color")
	if blood_array:
		blood_color = Color(blood_array[0], blood_array[1], blood_array[2], blood_array[3])
	var civs = parsedJSON.get("civilians")
	if civs:
		civilian_reduction = civs
	if parsedJSON.get("skip_intro"):
		skip_intro = parsedJSON.get("skip_intro")
	FOV = parsedJSON.get("FOV")
	var key_scancodes = $Menu.get_scancodes()
	if parsedJSON.get("keybinds"):
		key_scancodes = parsedJSON.get("keybinds")
	for scancode in range(key_scancodes.size()):
		if key_scancodes[scancode][1] == "KEY":
			match scancode:
				KEY_FORWARD:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("movement_forward", action)
				KEY_BACK:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("movement_backward", action)
				KEY_LEFT:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("movement_left", action)
				KEY_RIGHT:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("movement_right", action)
				KEY_JUMP:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("movement_jump", action)
				KEY_ZOOM:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("zoom", action)
				KEY_CROUCH:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("crouch", action)
				KEY_USE:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("Use", action)
				KEY_LEAN_LEFT:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("Lean_Left", action)
				KEY_LEAN_RIGHT:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("Lean_Right", action)
				KEY_WEAPON1:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("weapon1", action)
				KEY_WEAPON2:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("weapon2", action)
				KEY_LAST_WEAPON:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("switch_weapon", action)
				KEY_KICK:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("kick", action)
				KEY_SHOOT:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("mouse_1", action)
				KEY_RELOAD:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("reload", action)
				KEY_TERTIARY:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("Tertiary_Weapon", action)
				KEY_THROW_WEAPON:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("drop", action)
				KEY_SUICIDE:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("Suicide", action)
				KEY_STOCKS:
					var action = InputEventKey.new()
					action.scancode = key_scancodes[scancode][0]
					set_inputs("Stocks", action)
		elif key_scancodes[scancode][1] == "MOUSE":
			match scancode:
				KEY_FORWARD:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("movement_forward", action)
				KEY_BACK:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("movement_backward", action)
				KEY_LEFT:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("movement_left", action)
				KEY_RIGHT:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("movement_right", action)
				KEY_JUMP:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("movement_jump", action)
				KEY_ZOOM:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("zoom", action)
				KEY_CROUCH:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("crouch", action)
				KEY_USE:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("Use", action)
				KEY_LEAN_LEFT:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("Lean_Left", action)
				KEY_LEAN_RIGHT:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("Lean_Right", action)
				KEY_WEAPON1:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("weapon1", action)
				KEY_WEAPON2:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("weapon2", action)
				KEY_LAST_WEAPON:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("switch_weapon", action)
				KEY_KICK:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("kick", action)
				KEY_SHOOT:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("mouse_1", action)
				KEY_RELOAD:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("reload", action)
				KEY_TERTIARY:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("Tertiary_Weapon", action)
				KEY_THROW_WEAPON:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("drop", action)
				KEY_SUICIDE:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("Suicide", action)
				KEY_STOCKS:
					var action = InputEventMouseButton.new()
					action.button_index = key_scancodes[scancode][0]
					set_inputs("Stocks", action)
	
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_volume)
	
	settings.close()

func wait(c:int):
	for i in range(c):
		yield (get_tree(), "idle_frame")

func set_inputs(action, key):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, key)
