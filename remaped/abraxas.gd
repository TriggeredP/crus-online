extends Spatial

var t = 0

onready var torus = $"Armature/Skeleton/BoneAttachment 2/Torus"
onready var head = $Armature / Skeleton / BoneAttachment / Head
onready var anim = $AnimationPlayer
onready var laser = $"Armature/Skeleton/BoneAttachment 4/Right_Tail"
onready var rocket = $"Armature/Skeleton/BoneAttachment 3/Left_Tail"
const SPAWNS:Array = [preload("res://Entities/Enemies/E_Grunt_Meltdown.tscn"), preload("res://Entities/Enemies/E_Civilian_Meltdown.tscn"), preload("res://Entities/Enemies/E_Knifelord.tscn")]
var head_disabled = false
var enemy_spawn_frequency = 200
var kill_flag = false
var activated = false

puppet func set_animation(animation:String, speed:float)->void :
	anim.play(animation)
	anim.playback_speed = speed

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
	Global.objectives += 1

func _process(delta):
	torus.rotate_object_local(Vector3.BACK, deg2rad(1))

func _physics_process(delta):
	if is_network_master():
		t += 1
		
		if not activated and fmod(t, 20) == 0:
			var space = get_world().direct_space_state
			var result = space.intersect_ray(head.global_transform.origin, get_near_player(self).player.global_transform.origin + Vector3.UP * 0.5, [self, head])
			if result:
				if result.collider == Global.player or result.collider.has_meta("puppet"):
					activated = true
					head.active = true
			return 
		
		if not activated:
			return 
		
		if head.destroyed and laser.destroyed and rocket.destroyed and not kill_flag:
			kill_flag = true
			anim.play("Die")
			rpc("set_animation", "Die", 1)
			Global.remove_objective()
		
		elif not kill_flag:
			anim.play("Idle")
			rpc_unreliable("set_animation", "Idle", 1)
		
		if laser.destroyed or rocket.destroyed:
			enemy_spawn_frequency = 150
		if laser.destroyed and rocket.destroyed:
			enemy_spawn_frequency = 100
		if rocket.destroyed or head.destroyed:
			laser.disabled = false
		if head.destroyed and laser.destroyed:
			rocket.frequency = 20
		if head.destroyed and rocket.destroyed:
			laser.follow_speed = 0.1
		elif fmod(t, 200) == 0:
			if is_instance_valid(laser):
				laser.disabled = not laser.disabled
		if laser.destroyed or head.destroyed:
			rocket.disabled = false
		elif fmod(t, 150) == 0:
			if is_instance_valid(rocket):
				rocket.disabled = not rocket.disabled
		if fmod(t, enemy_spawn_frequency) == 0:
			if head.destroyed:
				return 
			
			var selectedEnemy = randi() % 3
				
			var new_enemy = SPAWNS[selectedEnemy].instance()
			
			new_enemy.set_name(new_enemy.name + "#" + str(randi() % 100000000))
			
			get_parent().add_child(new_enemy)
			new_enemy.global_transform.origin = head.global_transform.origin
			
			rpc("spawn_enemy", selectedEnemy, get_parent().get_path(), new_enemy.name, new_enemy.global_transform)
			
			yield (get_tree(), "idle_frame")
			new_enemy.add_velocity(40, (global_transform.origin - get_near_player(self).player.global_transform.origin).normalized())

puppet func spawn_enemy(selectedEnemy, parentPath, enemyName, enemyTransform):
	var new_enemy = SPAWNS[selectedEnemy].instance()
	get_node(parentPath).add_child(new_enemy)
	new_enemy.set_name(enemyName)
	new_enemy.global_transform = enemyTransform
	
