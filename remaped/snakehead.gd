extends KinematicBody

enum I{GOLEM, WEAPON, MONEY}
export (I) var index = I.GOLEM
var type = 1
var laser
var health = 2500
var death_flag = false
var follow_speed = 0.02
var particle
var active = false
var destroyed = false
var look_towards = Vector3.ZERO
var t = 0
var disabled = false
var gib = preload("res://Entities/Physics_Objects/Snake_Gib.tscn")
export  var line = "Triagon 01 is gone. (Golem Exosystem Received)"
export  var line2 = "I bestow upon you power."

func _ready():
	if Global.DEAD_CIVS.find(line) != - 1:
		get_parent().hide()
		queue_free()
	look_towards = Global.player.global_transform.origin
	laser = $Laser
	particle = $Particles

func _process(delta):
	t += 1
	if destroyed:
		hide()
		return 
	if disabled:
		particle.hide()
		if laser.scale.z < 3:
			hide()
		laser.scale.z = lerp(laser.scale.z, 1, 0.2)
		return 
	show()
	look_towards = lerp(look_towards, Global.player.global_transform.origin, follow_speed)
	var space = get_world().direct_space_state
		
	if not active:
		return 
		
	var result = space.intersect_ray(global_transform.origin, global_transform.origin - (global_transform.origin - look_towards).normalized() * 1000, [self])
	if result:
		particle.show()
		particle.global_transform.origin = result.position
		laser.scale.z = lerp(laser.scale.z, global_transform.origin.distance_to(result.position) * 0.5, 0.2)
		laser.look_at(result.position, Vector3.UP)
		if result.collider == Global.player:
			Global.player.damage(20, result.normal, result.position, global_transform.origin)
	else :
		particle.hide()
		laser.scale.z = 400

master func damage(dmg, nrml, pos, shoot_pos):
	if death_flag:
		return 
	active = true
	health -= dmg
	if health <= 0:
		death_flag = true
		if index == I.GOLEM:
			Global.implants.purchased_implants.append("CSIJ Level VI Golem Exosystem")
		if index == I.MONEY:
			Global.money += 1000000
		if index == I.WEAPON:
			Global.WEAPONS_UNLOCKED[Global.player.weapon.W_SHOCK] = true
		var new_gib = gib.instance()
		Global.player.get_parent().add_child(new_gib)
		new_gib.global_transform.origin = global_transform.origin
		Global.player.UI.notify(line, Color(0, 1, 0))
		Global.player.UI.message(line2, true)
		Global.DEAD_CIVS.append(line)
		Global.save_game()
		get_parent().queue_free()

func get_type():
	return type;
