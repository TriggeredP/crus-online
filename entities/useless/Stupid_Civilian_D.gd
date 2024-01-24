extends "res://MOD_CONTENT/CruS Online/entities/useless/EnemyHandler_D.gd"

var dead = false
var tranq = false
var water = false

onready var mesh = $Nemesis/Armature/Skeleton
onready var animation = $Nemesis/AnimationPlayer

var optimization_multiplier = 3
var last_pos:Vector3

onready var parent = get_parent()

puppet func play_anim(anim,blend = -1.0,speed = 1.0):
	animation.play(anim,blend,speed)

puppet func stop_anim():
	animation.stop()

func look_to(position):
	parent.look_at(position,Vector3.UP)
	parent.rotation.x = 0
	
	animation.play("Idle")
	rpc("play_anim","Idle")

func _ready():
	rset_config("global_transform",MultiplayerAPI.RPC_MODE_PUPPET)

func _physics_process(delta):
	if is_network_master():
		if not is_on_floor():
			velocity.y -= gravity * delta
		
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			if velocity.y < -5 * optimization_multiplier and abs(global_transform.origin.y - last_pos.y) > 7 and fallDamage:
				get_parent().damage(50, collision.normal, collision.position, collision.position)
			elif collision.normal.y > 0.9:
				velocity = velocity.slide(collision.normal)
				if dead or tranq:
					velocity.x *= 0.95
					velocity.z *= 0.95
			else :
				velocity = velocity.bounce(collision.normal)
				if Vector3(velocity.x, 0, velocity.z).length() > 0.5:
					mesh.look_at(global_transform.origin + Vector3(velocity.x, 0, velocity.z) + Vector3(0.0001, 0, 0), Vector3.UP)
					mesh.rotation.x = 0
			last_pos = global_transform.origin
		
		if Vector3(velocity.x, 0, velocity.z).length() > 0.5 and not dead and not tranq:
			if not alerted:
				animation.play("Walk")
				rpc("play_anim","Walk")
			else :
				animation.play("Run", -1, 2)
				rpc("play_anim","Run", -1, 2)
		
		if water:
			if not dead:
				gravity = - 4
			else :
				gravity = 1
		else :
			gravity = 22
		
		if get_tree().network_peer != null:
			rset_unreliable("global_transform",global_transform)

#var GRAVITY = 22
#export  var move_speed = 2
#export  var run_speed = 6
#export  var immune_to_fall_damage = false
#var optimization_multiplier = 3
#var velocity = Vector3(0, 0, 0)
#var setup = true
#var visibility_notifier:VisibilityNotifier
#var mesh
#var water = false
#var time = 0
#var anim_player:AnimationPlayer
#export (Array, String, MULTILINE) var LINES
#export (Array, Array, String, MULTILINE) var DYN_LINES = [["N"], 
#["N"], 
#["N"], 
#["N"], 
#["N"], 
#["N"], 
#["N"], 
#["N"], 
#["N"], 
#["N"], 
#["N"], 
#["N"], 
#["N"], ]
#
#var player_distance = Vector3.ZERO
#var flee = false
#var dead = false
#var tranq = false
#export  var free = false
#var active = false
#var current_line = 0
#var DEATH_ANIMS = ["Death1", "Death2"]
#var look_at_player = false
#var objective = false
#var last_pos:Vector3
#var random_line
#var glob
#var soul
#var tranqtimer:Timer
#
#func _ready():
#	soul = get_parent()
#	glob = Global
#	tranqtimer = Timer.new()
#	add_child(tranqtimer)
#	tranqtimer.wait_time = 60
#	tranqtimer.one_shot = true
#	tranqtimer.connect("timeout", self, "tranq_timeout")
#	set_process(false)
#	random_line = randi() % glob.DIALOGUE.DIALOGUE[glob.CURRENT_LEVEL].size()
#	last_pos = global_transform.origin
#	objective = get_parent().objective
#	if glob.CURRENT_LEVEL != 7 or objective:
#		optimization_multiplier = 1
#	time += round(rand_range(0, 50))
#	anim_player = get_parent().get_node_or_null("Nemesis/AnimationPlayer")
#	mesh = get_parent().get_node_or_null("Nemesis/Armature/Skeleton")
#	visibility_notifier = VisibilityNotifier.new()
#	visibility_notifier.connect("screen_entered", self, "_on_Screen_Entered")
#	visibility_notifier.connect("screen_exited", self, "_on_Screen_Exited")
#	if glob.CURRENT_LEVEL == 2000 and not objective:
#		move_speed = move_speed * optimization_multiplier * optimization_multiplier
#		run_speed *= optimization_multiplier * optimization_multiplier
#		GRAVITY *= optimization_multiplier
#	add_child(visibility_notifier)
#	visibility_notifier.global_transform.origin = global_transform.origin
#	velocity = Vector3(move_speed, 0, 0).rotated(Vector3.UP, rand_range(0, deg2rad(360)))
#	mesh.look_at(global_transform.origin + Vector3(velocity.x, 0, velocity.z), Vector3.UP)
#	player_distance = global_transform.origin.distance_to(glob.player.global_transform.origin)
#	var collision = move_and_collide(velocity)
#	yield (get_tree(), "idle_frame")
#	set_collision_layer_bit(8, 1)
#
#
#
#	if rand_range(0, 100) > glob.civilian_reduction and not objective and LINES.size() == 0 and glob.civilian_reduction != 101 and not get_parent().hell_objective and not get_parent().chaos_objective:
#		print(glob.civ_count_total)
#		if get_parent().hell_objective:
#			return 
#		if get_parent().chaos_objective:
#			return 
#		glob.civ_count -= 1
#		glob.civ_count_total -= 1
#		get_parent().queue_free()
#
#func _on_Screen_Entered():
#	active = true
#func _on_Screen_Exited():
#	if objective:
#		return 
#	active = false
#func _physics_process(delta):
#	if global_transform.origin.distance_to(glob.player.global_transform.origin) > glob.draw_distance + 10:
#		return 
#
#	var fps = Global.fps
#	if fmod(time, 22) == 0:
#		player_distance = global_transform.origin.distance_to(glob.player.global_transform.origin)
#		look_at_player = (player_distance < 4 or player_distance > 100)
#
#
#	time += 1
#	if player_distance > 40 and not dead and not tranq and not objective:
#		anim_player.play("Idle")
#		return 
#
#	if fps < 30:
#		if Global.every_2:
#			return 
#	var pos = global_transform.origin
#	var player_pos = glob.player.global_transform.origin
#	if not active and not dead and not flee and not free and not tranq:
#		return 
#
#	setup = false
#
#
#
#
#	if (look_at_player and not flee and not dead and not free and not tranq):
#		mesh.look_at(player_pos, Vector3.UP)
#		mesh.rotation.x = 0
#
#		velocity.x = 0
#		velocity.z = 0
#		anim_player.play("Idle")
#		return 
#
#
#
#
#
#
#
#	if fmod(time, 200) == 0 and not flee and not tranq:
#		var rand = randi() % 3
#		match rand:
#			1:
#				velocity.x = 0
#				velocity.z = 0
#			2:
#				velocity = Vector3(move_speed, velocity.y, velocity.z).rotated(Vector3.UP, rand_range(0, deg2rad(360)))
#				mesh.look_at(pos + Vector3(velocity.x, 0, velocity.z) + Vector3(0.0001, 0, 0), Vector3.UP)
#				mesh.rotation.x = 0
#			3:
#				pass
#	if Vector3(velocity.x, 0, velocity.z).length() > 0.5 and not dead and not tranq:
#		if not flee:
#			anim_player.play("Walk")
#		else :
#			anim_player.play("Run", - 1, 2)
#	elif not dead and not tranq:
#		anim_player.play("Idle")
#	if water:
#		if not dead:
#			GRAVITY = - 4
#		else :
#			GRAVITY = 1
#	else :
#		GRAVITY = 22
#		if glob.CURRENT_LEVEL == 2000 and not objective:
#			GRAVITY = 22 * optimization_multiplier
#	velocity.y -= GRAVITY * delta
#	var a = 1
#	if not fmod(time, 3) == 0 and glob.CURRENT_LEVEL == 2000 and not objective:
#		return 
#	if glob.CURRENT_LEVEL == 2000 and not objective:
#		a = 1.5
#	var collision = move_and_collide(velocity * delta)
#	if collision:
#		if velocity.y < - 5 * optimization_multiplier and abs(global_transform.origin.y - last_pos.y) > 7 and not immune_to_fall_damage:
#			get_parent().damage(50, collision.normal, collision.position, collision.position)
#		elif collision.normal.y > 0.9:
#			velocity = velocity.slide(collision.normal)
#			if dead or tranq:
#				velocity.x *= 0.95
#				velocity.z *= 0.95
#		else :
#			velocity = velocity.bounce(collision.normal)
#			if Vector3(velocity.x, 0, velocity.z).length() > 0.5:
#				mesh.look_at(pos + Vector3(velocity.x, 0, velocity.z) + Vector3(0.0001, 0, 0), Vector3.UP)
#				mesh.rotation.x = 0
#		last_pos = global_transform.origin
#func add_velocity(increase_velocity):
#	if not glob.CURRENT_LEVEL == 2000:
#		velocity -= increase_velocity
#	else :
#		velocity -= increase_velocity * optimization_multiplier
#
#func alert(peepee):
#	if LINES.size() != 0:
#		return 
#	set_flee()
#
#func set_water(a):
#	water = a
#	move_speed = 0
#	velocity.x = 0
#	velocity.z = 0
#	velocity.y *= 0.1
#
#func set_flee():
#	if not flee:
#		flee = true
#		set_collision_layer_bit(8, 0)
#		if not water:
#			move_speed = run_speed
#		velocity = Vector3(move_speed, 0, 0).rotated(Vector3.UP, rand_range(0, deg2rad(360)))
#		mesh.look_at(global_transform.origin + Vector3(velocity.x, 0, velocity.z) + Vector3(0.0001, 0, 0), Vector3.UP)
#		mesh.rotation.x = 0
#func set_dead():
#	if not dead:
#		set_collision_layer_bit(8, 0)
#		dead = true
#		if not tranq:
#			anim_player.play(DEATH_ANIMS[randi() % DEATH_ANIMS.size()])
#func set_tranquilized():
#	if not tranq:
#		set_collision_layer_bit(8, 0)
#		tranq = true
#		anim_player.play(DEATH_ANIMS[0])
#		tranqtimer.start()
#func tranq_timeout():
#	if dead:
#		return 
#	while (anim_player.is_playing() and anim_player.current_animation == DEATH_ANIMS[0]):
#		yield (get_tree(), "idle_frame")
#	if not dead:
#		anim_player.play("Idle", - 1)
#		tranq = false
#		flee = false
#		set_collision_layer_bit(8, 1)
#func player_use():
#	if not dead and not flee and not tranq:
#		if glob.implants.torso_implant.terror:
#			set_flee()
#			return 
#		if LINES.size() == 0:
#			glob.player.UI.message(glob.DIALOGUE.DIALOGUE[glob.CURRENT_LEVEL][random_line], true)
#		else :
#			if DYN_LINES[clamp(glob.LEVELS_UNLOCKED, 1, 12)][0] != "N":
#				glob.player.UI.message(DYN_LINES[glob.LEVELS_UNLOCKED][current_line], true)
#				current_line = clamp(current_line + 1, 0, DYN_LINES[glob.LEVELS_UNLOCKED].size() - 1)
#			else :
#				glob.player.UI.message(LINES[current_line], true)
#				current_line = clamp(current_line + 1, 0, LINES.size() - 1)
