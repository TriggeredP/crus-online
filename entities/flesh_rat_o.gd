extends KinematicBody

var GRAVITY = 22
export  var move_speed:float = 2
export  var attack_distance = 1
export  var run_speed = 6
export  var anim_speed = 1
export  var jumper = true
export  var immortal = false
var immortal_death_time = 200
var velocity = Vector3(0, 0, 0)
var weapon
var mesh
var _floor = false
var water = false
var time = 0
var anim_player:AnimationPlayer
var flee = false
var dead = false
var chatter_sound
var chatter_on = false
var DEATH_ANIMS = ["Death1", "Death2"]

# Multiplayer stuff
################################################################################

func get_near_player(object) -> Dictionary:
	var oldDistance = null
	var checkPlayer = null
	
	for selectedPlayer in get_tree().get_nodes_in_group("Player"):
		var distance = object.global_transform.origin.distance_to(selectedPlayer.global_transform.origin)
		if oldDistance == null or oldDistance > distance:
			oldDistance = distance
			checkPlayer = selectedPlayer
	
	return {
		"player" : checkPlayer,
		"distance" : oldDistance
	}

################################################################################

func _ready():
	rset_config("global_transform",MultiplayerAPI.RPC_MODE_PUPPET)
	
	set_process(false)
	if immortal:
		get_parent().immortal = true
	weapon = $Rotation_Helper / Weapon
	time += round(rand_range(0, 50))
	anim_player = get_parent().get_node_or_null("Nemesis/AnimationPlayer")
	anim_player.play("Idle")
	mesh = get_parent().get_node_or_null("Nemesis/Armature/Skeleton")
	chatter_sound = get_node_or_null("SFX/Chatter")
	chatter_on = is_instance_valid(chatter_sound)
	velocity = Vector3(move_speed, 0, 0).rotated(Vector3.UP, rand_range(0, deg2rad(360)))
	look_at(global_transform.origin + Vector3(velocity.x, 0, velocity.z), Vector3.UP)
	yield (get_tree(), "idle_frame")
	get_parent().new_alert_sphere.get_node("CollisionShape").disabled = true
	
func _physics_process(delta):
	if is_network_master():
		rset_unreliable("global_transform", global_transform)
		
		var nearest_player = get_near_player(self)
		
		if nearest_player.distance > Global.draw_distance + 10:
			return 
		if immortal and dead:
			immortal_death_time -= 1
			if immortal_death_time == 0:
				get_parent().dead = false
				get_parent().dead_body.get_node("CollisionShape").disabled = true
				get_parent().torso.get_node("CollisionShape").disabled = false
				get_parent().health = 50
				dead = false
				immortal_death_time = 200
				anim_player.play("Undie")
				yield (get_tree(), "idle_frame")
		if nearest_player.distance > 20:
			velocity.x = 0
			velocity.z = 0
		elif not dead:
			if chatter_on:
				if not chatter_sound.playing:
					chatter_sound.play()
		time += 1
		if nearest_player.distance < 3 and not dead and _floor and nearest_player.distance > 1 and jumper:
			velocity *= 2
			velocity.y += 5
		if (nearest_player.distance < attack_distance or nearest_player.distance > 20) and not flee and not dead and not anim_player.current_animation == "Undie":
			look_at(nearest_player.player.global_transform.origin, Vector3.UP)
			rotation.x = 0
			velocity.x = 0
			velocity.z = 0
			if nearest_player.distance < attack_distance:
				weapon.AI_shoot()
				anim_player.play("Attack", - 1, 1)
		else :
			if fmod(time, 20) == 0 and not dead and not anim_player.current_animation == "Undie":
				velocity = - move_speed * (global_transform.origin - nearest_player.player.global_transform.origin).normalized()
				look_at(global_transform.origin + velocity, Vector3.UP)
				rotation.x = 0
			if Vector3(velocity.x, 0, velocity.z).length() > 0.4 and not dead and not anim_player.current_animation == "Undie":
				if not flee:
					anim_player.play("Walk", - 1, anim_speed)
				else :
					anim_player.play("Run", - 1, 2)
			elif not dead and not anim_player.current_animation == "Undie":
				anim_player.play("Idle")
		if water:
			GRAVITY = 2
		else :
			GRAVITY = 22
		velocity.y -= GRAVITY * delta
		if dead or anim_player.current_animation == "Undie":
			velocity.x *= 0.9
			velocity.z *= 0.9
		var collision = move_and_collide(velocity * delta)
		if collision:
			if collision.normal.y > 0.9:
				velocity = velocity.slide(collision.normal)
				_floor = true
			else :
				_floor = false
				velocity = velocity.bounce(collision.normal)
				if Vector3(velocity.x, 0, velocity.z).length() > 0.4:
					look_at(global_transform.origin + Vector3(velocity.x, 0, velocity.z) + Vector3(0.0001, 0, 0), Vector3.UP)
					rotation.x = 0
		else :
			_floor = false

master func add_velocity(increase_velocity):
	if is_network_master():
		velocity -= increase_velocity
	rpc("add_velocity", increase_velocity)

func set_water(a):
	if is_network_master():
		water = a
		velocity.y = 0

func set_flee():
	pass

master func set_dead():
	if is_network_master():
		if not dead:
			dead = true
			if not immortal:
				for child in get_parent().colliders.get_children():
					child.get_child(0).disabled = true
			anim_player.play(DEATH_ANIMS[randi() % DEATH_ANIMS.size()])
	else:
		rpc("set_dead")
