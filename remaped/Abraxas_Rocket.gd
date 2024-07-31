extends KinematicBody

var health = 300
var type = 1
var frequency = 50
var destroyed = false
var disabled = true
var BULLETS = preload("res://Entities/Bullets/Homing_Missile.tscn")
var fakeBULLETS = preload("res://MOD_CONTENT/CruS Online/effects/fake_Homing_Missile.tscn")
var t = 0
var activated = false

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

func _ready():
	pass

func _physics_process(delta):
	if is_network_master():
		t += 1
		if destroyed:
			return 
		if disabled:
			return 
		show()
		if not activated and fmod(t, 50) == 0:
			var space = get_world().direct_space_state
			var result = space.intersect_ray(global_transform.origin, get_near_player(self).player.global_transform.origin + Vector3.UP * 1.0, [self])
			if result:
				if result.collider == Global.player or result.collider.has_meta("puppet"):
					activated = true
		if activated:
			if fmod(t, frequency) == 0:
				for i in range(4):
					yield (get_tree(), "idle_frame")
					yield (get_tree(), "idle_frame")
					yield (get_tree(), "idle_frame")
					yield (get_tree(), "idle_frame")
					yield (get_tree(), "idle_frame")
					yield (get_tree(), "idle_frame")
					yield (get_tree(), "idle_frame")
					yield (get_tree(), "idle_frame")
					rocket_launcher()
	else:
		set_physics_process(false)

puppet func create_missile(parentPath, missileName, missileTransform):
	var missile_new = fakeBULLETS.instance()
	
	missile_new.set_name(missileName)
	get_node(parentPath).add_child(missile_new)
	missile_new.global_transform = missileTransform

func rocket_launcher()->void :
	var missile_new = BULLETS.instance()
	
	missile_new.set_name(missile_new.name + "#" + str(randi() % 1000000000))
	
	get_parent().get_parent().get_parent().add_child(missile_new)
	missile_new.add_collision_exception_with(self)
	missile_new.global_transform.origin = global_transform.origin
	missile_new.set_velocity(30, (global_transform.origin - (Global.player.global_transform.origin + Vector3.UP * 50 + Vector3(0, 0, sin(t * 0.5) * 25))).normalized(), global_transform.origin)
	
	rpc("create_missile", get_parent().get_parent().get_parent().get_path(), missile_new.name, missile_new.global_transform)

puppet func died():
	get_parent().get_node("Sphere001").hide()
	get_parent().get_node("Particle").show()

master func damage(dmg, nrml, pos, shoot_pos):
	if is_network_master():
		if not activated:
			return 
		health -= dmg
		if health <= 0:
			destroyed = true
			died()
			rpc("died")
	else:
		rpc("damage", dmg, nrml, pos, shoot_pos)

func get_type():
	return type;
