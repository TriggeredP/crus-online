extends Control
var t = 0
var health = 100
var shooter_pos = Vector2.ZERO
var shooter_line_length = 0
var shot_reticle_radius = 5
var min_shot_reticle_radius = 5
var max_shot_reticle_radius = 30
var hit_reticle_radius = 0
var min_hit_reticle_radius = 0
var max_hit_reticle_radius = 50
var UI_distance = 0
onready var play_time = $Ammovbox / HBoxContainer / VBoxContainer / Play_Time
var toxic = false
var comms_color = Color(1, 1, 1, 0)
var current_speaker = 0
const HEALTH = preload("res://Textures/UI/UILIFE.tres")
const DEATH = preload("res://Textures/UI/UIDEATH.tres")
var font = preload("res://Fonts/gamefont(1).ttf")
var sniper_lines:Array = ["I CAN SEE YOU", "TARGET ACQUIRED", "RUN PIG", "YOU CAN'T HIDE"]
var sniper_audio:Array = ["res://Sfx/Sniper/Seeyou.wav", "res://Sfx/Sniper/targetacquired.wav", "res://Sfx/Sniper/runpig.wav", "res://Sfx/Sniper/canthide.wav"]
onready var Toxic_UI = $UI_HBOX / Toxic
var stop = false
var snipe_timer = 0
var comms:VBoxContainer
var message_box:RichTextLabel
var ammo_rotation = 0
var reload_color = Color(0, 0, 0, 0)
var reload_pos = Vector2(0, 0)

var process_time = 0

var mag_ammo_c = 1
var ammo_c = 1
var max_mag_ammo_c = 1
var max_ammo_c = 1
onready var fps_label = $Ammovbox / HBoxContainer / VBoxContainer / FPS_label
onready var death_timer = $Death_Timer
onready var death_timer_label = $CenterContainer2 / Death_Timer_Label

var AMMO_TEXTURE = preload("res://Textures/UI/AMMO.png")
var MAG_TEXTURE = preload("res://Textures/UI/MAG.png")

const HANDLER_FRAMES:Array = [preload("res://Textures/Menu/Handler/1.png"), 
								preload("res://Textures/Menu/Handler/2.png"), 
								preload("res://Textures/Menu/Handler/3.png"), 
								preload("res://Textures/Menu/Handler/4.png")]
const CIV_FRAMES:Array = [preload("res://Textures/Menu/Civ_Mouth/1.png"), 
								preload("res://Textures/Menu/Civ_Mouth/2.png"), 
								preload("res://Textures/Menu/Civ_Mouth/3.png"), 
								preload("res://Textures/Menu/Civ_Mouth/4.png")]

var time_start
var time_now


var nd
var mdt
var mdt_edge_count
var m
var reload_font
var nd2
var mdt2
var mdt2_edge_count
var m2
onready var eyevbox = $Eyevbox
onready var health_texture = $UI_HBOX / TextureRect
var notify:Label


func _ready():
	time_now = OS.get_system_time_msecs()
	reload_font = $Notification_Box / Notification_Label.get_font("font")
	Global.UI = self
	Global.enemy_count = 0
	Global.civ_count = 0
	comms = $UI_COMMS_CONTAINER
	message_box = $UI_COMMS_CONTAINER / UI_COMMS / ScrollContainer / Message_Label
	time_start = OS.get_system_time_msecs()
	notify = $Notification_Box / Notification_Label
	
	mdt = MeshDataTool.new()
	nd = $MeshInstance
	m = nd.get_mesh()
	mdt.create_from_surface(m, 0)
	var a = mdt.get_edge_count()
	mdt_edge_count = a
	
	mdt2 = MeshDataTool.new()
	nd2 = $MeshInstance2
	m2 = nd2.get_mesh()
	mdt2.create_from_surface(m2, 0)
	var b = mdt2.get_edge_count()
	mdt2_edge_count = b
	
	max_shot_reticle_radius = Global.resolution[1] / 20
	max_hit_reticle_radius = Global.resolution[1] / 10
	
	reload_pos.x = 1280 / 2
	
	if Global.death:
		health_texture.texture = DEATH
	else :
		health_texture.texture = HEALTH

func message(msg:String, npc:bool):
	stop = true
	comms_color = Color(1, 1, 1, 0)
	yield (get_tree(), "idle_frame")
	stop = false
	if npc:
		current_speaker = 0
		$UI_COMMS_CONTAINER / UI_COMMS / ScrollContainer / Message_Label / AudioStreamPlayer.pitch_scale = 2
	else :
		$UI_COMMS_CONTAINER / UI_COMMS / ScrollContainer / Message_Label / AudioStreamPlayer.pitch_scale = 1.3
		current_speaker = 1
	comms_color = Color(1, 1, 1, 1)
	message_box.text = msg
	message_box.speech()
	while (message_box.visible_characters < message_box.text.length()):
		if stop:
			return 
		comms_color = Color(1, 1, 1, 1)
		yield (get_tree(), "idle_frame")
	var comms_timer = Timer.new()
	add_child(comms_timer)
	comms_timer.one_shot = true
	comms_timer.wait_time = 3
	comms_timer.connect("timeout", self, "comms_timeout")
	comms_timer.start()
	
func comms_timeout():
	if stop:
		return 
	comms_color = Color(1, 1, 1, 0)
func set_sniped(value):
	if value:
		if not $Eyevbox.visible:
			var rand_index = randi() % sniper_lines.size()
			notify(sniper_lines[rand_index], Color(0.8, 0.2, 0))
			$Sniper_Audio.stream = load(sniper_audio[rand_index])
			$Sniper_Audio.play()
			$Eyevbox.show()
func set_in_sight(value):
	if value:
		if not $Eyevbox.visible:
			snipe_timer = 10
			
			
			
			
			$Eyevbox.show()
func notify(message:String, color:Color):
	var new_notification:Label = notify.duplicate()
	$Notification_Box.add_child(new_notification)
	new_notification.visible_characters = 0
	new_notification.add_color_override("font_color", color)
	new_notification.text = message
	new_notification.show()
	$Notification_Box.move_child(new_notification, 0)
	for i in new_notification.text:
		new_notification.visible_characters += 1
		yield (get_tree(), "idle_frame")
	var notify_timer = Timer.new()
	add_child(notify_timer)
	notify_timer.wait_time = 3
	notify_timer.one_shot = true
	notify_timer.connect("timeout", self, "notify_timeout", [new_notification])
	notify_timer.start()
	










func notify_timeout(new_notification):
	for i in new_notification.text:
		new_notification.visible_characters -= 1
		yield (get_tree(), "idle_frame")
	new_notification.queue_free()
func _draw():
	
	
	draw_reload(reload_pos, reload_color)
	
	
	if health <= 0 and fmod(t, 3) == 0:
		draw_cube()
		draw_cube2()

func draw_reload(pos, color):
	draw_line(Vector2(pos.x, 0), Vector2(pos.x, 720), color)
	draw_line(Vector2(pos.x - 20, 720 / 2), Vector2(pos.x + 20, 720 / 2), color)
	draw_string(reload_font, Vector2(pos.x, 720 / 2), "Reload", color)
	draw_line(Vector2(pos.x - 20, pos.y), Vector2(pos.x + 20, pos.y), color)
	
func set_dead():
	$Died.visible = true

func set_shooter_pos(shotpos):
		shooter_line_length = 50
		shooter_pos = Vector2(shotpos.x, shotpos.z)

func set_health(new_health):
	$UI_HBOX / TextureRect / Health.text = str(ceil(new_health))
	health = float(ceil(new_health))
func set_ammo(ammo, mag_ammo, max_mag_ammo, max_ammo):
	$Ammovbox / HBoxContainer / Ammo.text = str(ammo)
	
	ammo_c = ammo
	ammo_rotation += 2
	mag_ammo_c = mag_ammo
	max_ammo_c = max_ammo
	max_mag_ammo_c = max_mag_ammo
	
	$Ammovbox / HBoxContainer / Mag_Ammo.text = str(mag_ammo)
func _physics_process(delta):
	$Ammovbox / HBoxContainer / Ammo_Image.rect_rotation += ammo_rotation
	ammo_rotation = lerp(ammo_rotation, 0, 0.1)
	comms.modulate = lerp(comms.modulate, comms_color, 0.1)
	
	snipe_timer -= 1
	if snipe_timer == 0:
		eyevbox.hide()
	var elapsed = (time_now - time_start) / 1000
	var elapsed_msecs = time_now - time_start
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	var milseconds = elapsed_msecs % 1000
	Global.level_time = str(minutes, ".", seconds, ".", milseconds)
	Global.level_time_raw = time_now - time_start
	t += 1
	shooter_line_length = lerp(shooter_line_length, 0, 0.2)
	shot_reticle_radius = lerp(shot_reticle_radius, min_shot_reticle_radius, 0.2)
	hit_reticle_radius = lerp(hit_reticle_radius, min_hit_reticle_radius, 0.2)
	if health < 0:
		health = 0
	if health <= 0 or Input.is_action_pressed("reload"):
		update()
	
	rect_scale.x = Global.resolution[0] / 1280
	rect_scale.y = Global.resolution[1] / 720
	margin_left = Global.resolution[0] / 8
	margin_top = Global.resolution[1] / 10
	health_texture.texture.fps = clamp(100 - health, 24, 100)
	var h = health
	if Global.death:
		h += 250
	var clr = Color(1 - h * 0.01, h * 0.01, 0).from_hsv((h * 0.01) * 0.25, 1, 1)
	health_texture.modulate = clr
	
	
	if Global.timer:
		fps_label.show()
		play_time.show()
		fps_label.text = str(Global.level_time)
		play_time.text = Global.time2str(Global.play_time)
	else :
		fps_label.hide()
		play_time.hide()
	if Global.player.died:
		death_timer_label.text = str(stepify(death_timer.time_left, 0.01))
func _process(delta):
	process_time += 1
	
	if fmod(process_time, 2) == 0 and toxic:
		Toxic_UI.visible = not Toxic_UI.visible
	elif Toxic_UI.visible == true:
		Toxic_UI.hide()
func shot_line(v):
	var screen_center = Vector2(Global.resolution[0] / 2, Global.resolution[1] / 2)
	draw_line(screen_center, screen_center + v * shooter_line_length, ColorN("red"))

func draw_sine():
	var line_offset = 1
	var x = 20
	var y = Global.resolution[1] - Global.resolution[1] / 10

	var width = Global.resolution[0] / 3
	var a = Global.resolution[1] / 20
	for line in range(width):
		var health_calc = 10 / (health + 1e-05)
		draw_line(Vector2(x, y + tan(sin(tan(sin(tan(x * 0.005 + t * health_calc * 1))))) * a * health * 0.01 * rand_range(0.9, 1)), 
		Vector2(x + 1, y + tan(sin(tan(sin(tan(x * 0.005 + (t * health_calc) * 1))))) * a * health * 0.01 * rand_range(0.9, 1)), 
		Color(health_calc * 5, health * 0.1, 0))
		x += 1
		

func draw_ammo():
	return 
	var total_x_offset = 0
	var x_size = 16
	x_size = sin(t * 0.01) * 8 + 20
	var total_y_offset = 0
	var y_size = 16
	for i in range(mag_ammo_c):
		var x_offset = x_size
		var y_offset = y_size
		if fmod(i, 10) == 0 and i != 0:
			total_y_offset -= y_offset
			total_x_offset = 0
		draw_texture_rect(AMMO_TEXTURE, Rect2(Vector2(5 + total_x_offset, 500 + total_y_offset + sin(t * 0.05) * 2), Vector2(x_size, y_size)), false)
		total_x_offset += x_offset
	
	total_x_offset = 0
	total_y_offset = 0
	y_size = 32
	x_size = cos(t * 0.01) * 12 + 20
	var mag_count = (max_ammo_c / max_mag_ammo_c) + (ammo_c / max_mag_ammo_c) - (max_ammo_c / max_mag_ammo_c)
	if ammo_c > 0 and mag_count > 0:
		mag_count = 1
	for i in range(mag_count):
		var x_offset = x_size
		var y_offset = y_size
		draw_texture_rect(MAG_TEXTURE, Rect2(Vector2(5 + total_x_offset, 400 + total_y_offset), Vector2(x_size, y_size)), false)
		total_x_offset += x_offset

func draw_health():
	var x = 100
	var y = 100
	var f = 0.05
	var a = 50
	var width = 50
	for i in range(width):
		a = clamp(health, 10, 50)
		draw_line(Vector2(x, y), Vector2(x + sin((TAU + t + i) * f) * a + cos((TAU + t + i) * f * 0.5) * a, 
		y + cos((TAU + t + i) * f) * a + sin((TAU + t + i) * f * 0.1) * a), Color(1 - health * 0.01, health * 0.01, 0, float(i) / width), 2)

func draw_reticle():
	draw_circle(Vector2(Global.resolution[0] / 2, Global.resolution[1] / 2), 2, ColorN("red"))
	draw_empty_circle(Vector2(Global.resolution[0] / 2, Global.resolution[1] / 2), Vector2(shot_reticle_radius, shot_reticle_radius), ColorN("red"), 7, false)
	draw_empty_circle(Vector2(Global.resolution[0] / 2, Global.resolution[1] / 2), Vector2(0, hit_reticle_radius), Color(0, 1, 0), 2, false)
	draw_empty_circle(Vector2(Global.resolution[0] / 2, Global.resolution[1] / 2), Vector2(hit_reticle_radius, 0), Color(0, 1, 0), 2, false)
	draw_line(Vector2(Global.resolution[0] / 2 - UI_distance, Global.resolution[1] / 2 - UI_distance), Vector2(Global.resolution[0] / 2 + UI_distance, Global.resolution[1] / 2 + UI_distance), Color(0, 1, 0))
	
		

func draw_empty_circle(circle_center, circle_radius, color, resolution, to_center):
	var draw_counter = 1
	var line_origin = Vector2()
	var line_end = Vector2()
	line_origin = circle_center + circle_radius

	for line in range(resolution):
		line_end = circle_radius.rotated(deg2rad(draw_counter)) + circle_center
		draw_line(line_origin, line_end, color)
		if to_center:
			draw_line(line_origin, Vector2(1280 / 2, 720 / 2), ColorN("red"))
		draw_counter += 360 / resolution
		line_origin = line_end
		line_end = circle_radius.rotated(deg2rad(resolution)) + circle_center
	line_end = circle_radius.rotated(deg2rad(draw_counter)) + circle_center
	draw_line(line_origin, line_end, color)
	
func draw_cube():
	var draw_pos = Vector2(1280 * 0.65, 720 * 0.3)
	var draw_size = Vector2(1280, 720) * 0.2
	
	
	for edg in range(mdt_edge_count):
		var vert1 = mdt.get_vertex(mdt.get_edge_vertex(edg, 0))
		var vert2 = mdt.get_vertex(mdt.get_edge_vertex(edg, 1))
		draw_line(Vector2(draw_pos.x + vert1.x + sin(PI * 2 + t * 0.05) * vert1.z * draw_size.x + cos(PI * 2 + t * 0.05) * draw_size.x * vert1.x, - vert1.y * draw_size.x + draw_pos.y), 
		Vector2(draw_pos.x + vert2.x + sin(PI * 2 + t * 0.05) * vert2.z * draw_size.x + cos(PI * 2 + t * 0.05) * draw_size.x * vert2.x, - vert2.y * draw_size.x + draw_pos.y), Color(0, 1, 0, clamp(vert1.z + 1, 0, 1)))
		

func draw_cube2():
	var draw_pos = Vector2(1280 * 0.65, 720 * 0.3)
	var draw_size = Vector2(1280, 720) * 0.2
	draw_empty_circle(draw_pos, Vector2(draw_size.x * sin(t * 0.05) * 0.7, draw_size.y * sin(t * 0.1) * 0.8), ColorN("red"), 5, true)
	for edg in range(mdt2_edge_count):
		var vert1 = mdt2.get_vertex(mdt2.get_edge_vertex(edg, 0))
		var vert2 = mdt2.get_vertex(mdt2.get_edge_vertex(edg, 1))
		draw_line(Vector2(draw_pos.x + vert1.x + sin(PI * 2 + t * 0.05) * vert1.z * draw_size.x + cos(PI * 2 + t * 0.05) * draw_size.x * vert1.x, - vert1.y * draw_size.x + draw_pos.y), 
		Vector2(draw_pos.x + vert2.x + sin(PI * 2 + t * 0.05) * vert2.z * draw_size.x + cos(PI * 2 + t * 0.05) * draw_size.x * vert2.x, - vert2.y * draw_size.x + draw_pos.y), Color(1, 0, 0, clamp(vert1.z + 1, 0, 1)))


func hit():
	hit_reticle_radius = max_hit_reticle_radius
func shoot():
	shot_reticle_radius = max_shot_reticle_radius
func distance(distance):
	UI_distance = distance
	$CenterContainer / Distance_Label.text = str(stepify(distance, 0.01))
	pass

func set_death_timer(tim,disable = true):
	if disable:
		$Death_Timer.start(tim)
		$CenterContainer2 / Death_Timer_Label.show()
	else:
		$Death_Timer.stop()
		$CenterContainer2 / Death_Timer_Label.hide()


func _on_Message_Label_character_speak():
	if current_speaker == 1:
		$UI_COMMS_CONTAINER / UI_COMMS / Character_Portrait.texture = HANDLER_FRAMES[randi() % 3]
	else :
		$UI_COMMS_CONTAINER / UI_COMMS / Character_Portrait.texture = CIV_FRAMES[randi() % 3]
