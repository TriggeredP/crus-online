extends Spatial

export  var npc_name = "Generic_NPC"
export  var health = 100
export  var armor = 0
export  var armored = false
export  var random_spawn = false
export  var flee_health = 25
export  var gib_health = - 50
export  var civilian = false
export  var permadeath = false
export  var psychosis_inducer = false
export  var stupid = false
export  var creature = false
export  var objective = false
export  var chaos_objective = false
export  var gib = true
export  var notarget = false
export  var edible = true
export  var hell_objective = false
export  var cancer_immunity = false
export  var stealth = false
var immortal = false
var t = 0
var body
var alerted = false
var grilled_flag = false
var skeleton
var torso
var torso_mesh
var stealth_random = false
var head
var head_mesh
var legs
var leg_mesh
onready var colliders = $Collisions
var weapon
var weapon_drop = preload("res://Entities/Objects/Gun_Pickup.tscn")
var grilled_material = preload("res://Materials/grilled.tres")
var dead = false
var flee = false
var on_fire = false
var player_seen = false
var rand_objective = false
var alert_sphere = preload("res://Entities/Alert_Sphere.tscn")
onready var pain_sfx = [$Body / SFX / Pain1]
onready var gib_sfx = $Body / SFX / Gib

var gibs_spawned = false
var glob
var dead_head
var dead_body
export  var AMMO:PackedScene
var stealthmat = preload("res://Materials/stealth_enemy.tres")
var SELF_DESTRUCT = preload("res://Entities/Bullets/Poison_Gas.tscn")
var HEARTBEAT_INDICATOR = preload("res://Entities/Enemies/Heartbeat_Indicator.tscn")
var heartbeat
export  var poison_death:bool = false
export (Array, PackedScene) var GIBS = [preload("res://Entities/Physics_Objects/Chest_Gib.tscn"), 
preload("res://Entities/Physics_Objects/Leg_Gib.tscn"), 
preload("res://Entities/Physics_Objects/Leg_Gib.tscn"), 
preload("res://Entities/Physics_Objects/Arm_Gib.tscn"), 
preload("res://Entities/Physics_Objects/Arm_Gib.tscn"), 
preload("res://Entities/Physics_Objects/Head_Gib.tscn")]
export (Array, PackedScene) var DROPS = [
	preload("res://Entities/Physics_Objects/ORG_Liver.tscn"), 
	preload("res://Entities/Physics_Objects/ORG_Brain.tscn"), 
	preload("res://Entities/Physics_Objects/ORG_Heart.tscn"), 
	preload("res://Entities/Physics_Objects/ORG_Pancreas.tscn"), 
	preload("res://Entities/Physics_Objects/ORG_Intestine.tscn"), 
	preload("res://Entities/Physics_Objects/ORG_Stomach.tscn"), 
	preload("res://Entities/Physics_Objects/ORG_Kidney.tscn"), 
	preload("res://Entities/Physics_Objects/ORG_Appendix.tscn"), 
	preload("res://Entities/Physics_Objects/ORG_Spine.tscn"), 
	]
export (Array, float) var DROP_CHANCE = [
	50, 
	15, 
	5, 
	10, 
	4, 
	10, 
	50, 
	0.1, 
	1, 
]

export  var drop_chance = 1
var G_CHEST = preload("res://Entities/Physics_Objects/Chest_Gib.tscn")
var G_LEG = preload("res://Entities/Physics_Objects/Leg_Gib.tscn")
var G_ARM = preload("res://Entities/Physics_Objects/Arm_Gib.tscn")
var G_HEAD = preload("res://Entities/Physics_Objects/Head_Gib.tscn")
var P_BLOOD = preload("res://Entities/Particles/Blood_Particle.tscn")
var P_BLOOD_2 = preload("res://Entities/Particles/Blood_Particle3.tscn")
var P_BLOODS = Array()
var firesound = preload("res://Sfx/NPCs/firedeath2.wav")
var all_particles:Array = Array()
var objective_material = preload("res://Materials/See_Through_Red.tres")
var regular_material
var new_alert_sphere
var healthy_material = preload("res://Materials/mainguy.tres")
var armored_material = preload("res://Materials/rod.tres")
var healthy_random = false
var armored_random = false
var nodamage
onready var collisions = $Collisions

var bodypos
var nearby:Array
var deathtimer:Timer
var tranqtimer:Timer
var poisontimer:Timer
var fireaudio:AudioStreamPlayer3D

# Multiplayer stuff
################################################################################

puppet func _spawn_gib_client(gib, damage, collision_n, collision_p, gibType, gibName):
	var new_gib = self[gibType][gib].instance()
	new_gib.set_name(new_gib.name + "#" + str(gibName))
		
	new_gib.set_meta("syncData",{
		"assetPath": self[gibType][gib].resource_path,
		"syncProperties": [
			"global_transform"
		]
	})
		
	get_tree().get_nodes_in_group("Sync")[0].add_child(new_gib)

################################################################################

func cleanup():
	if is_network_master():
		queue_free()

puppet func set_stealth():
	if not stealth:
		return 
	skeleton.get_node("Armature/Skeleton/Cube").material_override = stealthmat
	if is_network_master():
		rpc("set_stealth")

func _ready():
	nodamage = get_node_or_null("Body/SFX/NoDamage")
	if nodamage == null:
		nodamage = AudioStreamPlayer3D.new()
		$Body.add_child(nodamage)
		nodamage.stream = load("res://Sfx/bullet_impact_metal.wav")
		nodamage.unit_size = 10
	set_process(false)
	glob = Global
	if hell_objective and not glob.hope_discarded:
		queue_free()
		return 
	elif hell_objective and (glob.hope_discarded):
		objective = true
	
	if (chaos_objective and not glob.chaos_mode):
		queue_free()
		return 
	if chaos_objective and rand_range(0, 100) > 25:
		queue_free()
		return 
	if glob.chaos_mode:
		if rand_range(0, 100) < 10:
			stealth_random = true
		if chaos_objective:
			objective = true
		if rand_range(0, 100) < 10:
			poison_death = true
		if rand_range(0, 100) < 10:
			healthy_random = true
		if rand_range(0, 100) < 10:
			armored_random = true
	if not civilian and glob.hope_discarded:
		if health < 70 and health > 20:
			health = 70
	if glob.DEAD_CIVS.find(npc_name) != - 1:
		queue_free()
	if glob.hope_discarded:
		pass
	elif (glob.ending_1 or glob.punishment_mode) and random_spawn:
		randomize()
		if randi() % 25 != 4:
			queue_free()
	elif random_spawn:
		randomize()
		if randi() % 250 != 4:
			queue_free()
	deathtimer = Timer.new()
	add_child(deathtimer)
	deathtimer.wait_time = 25
	deathtimer.connect("timeout", self, "cleanup")
	tranqtimer = Timer.new()
	add_child(tranqtimer)
	tranqtimer.wait_time = 2
	tranqtimer.one_shot = true
	tranqtimer.connect("timeout", self, "tranq_timeout", [true])
	poisontimer = Timer.new()
	add_child(poisontimer)
	poisontimer.wait_time = 1
	poisontimer.one_shot = true
	poisontimer.connect("timeout", self, "poison_timeout")
	body = $Body
	fireaudio = AudioStreamPlayer3D.new()
	body.add_child(fireaudio)
	fireaudio.global_transform.origin = body.global_transform.origin
	fireaudio.stream = firesound
	fireaudio.unit_size = 10
	fireaudio.max_db = 0
	skeleton = $Nemesis
	torso = $Collisions / Torso
	head = $Collisions / Head
	legs = $Collisions / Legs
	new_alert_sphere = alert_sphere.instance()
	body.add_child(new_alert_sphere)
	new_alert_sphere.global_transform.origin = body.global_transform.origin
	if not civilian:
		weapon = get_node_or_null("Body/Rotation_Helper/Weapon")
		glob.enemy_count += 1
		glob.enemy_count_total = glob.enemy_count
	elif not objective:
		glob.civ_count += 1
		glob.civ_count_total = glob.civ_count
	if objective:
		glob.add_objective()
		$Body / Objective_Indicator.show()
	if objective:
		print(glob.objectives)
		print(name)
	dead_head = $Collisions / Dead_Head
	dead_body = $Collisions / Dead_Body
	bodypos = body.global_transform.origin
	torso_mesh = get_node_or_null("Nemesis/Armature/Skeleton/Torso_Mesh")
	if torso_mesh != null:
		if healthy_random and health < 199:
			torso_mesh.material_override = healthy_material
			health = 199
		if armored_random and not armored:
			torso_mesh.material_override = armored_material
			armored = true
			armor = 50
		if stealth_random:
			torso_mesh.material_override = stealthmat
	if not creature:
		head_mesh = $Nemesis / Armature / Skeleton / Head_Mesh
		if stealth_random:
			head_mesh.material_override = stealthmat
	remove_child(skeleton)
	body.add_child(skeleton)
	remove_child(colliders)
	body.add_child(colliders)
	if glob.implants.head_implant.sensor:
		var new_heartbeat = HEARTBEAT_INDICATOR.instance()
		body.add_child(new_heartbeat)
		new_heartbeat.global_transform.origin = body.global_transform.origin + Vector3.UP * 0.25
		heartbeat = new_heartbeat

func _physics_process(delta):
	if is_network_master():
		if on_fire:
			var dist_clamped = clamp(body.global_transform.origin.distance_to(glob.player.global_transform.origin), 0.1, 20)
			pain_sfx[0].pitch_scale = 0.5 + ((dist_clamped - 0.1) / (20 - 0.1))
		t += 1

master func set_tranquilized(dart):
	if is_network_master():
		tranqtimer.start()
	else:
		rpc_id(0,"set_tranquilized",null)

func tranq_timeout(dart):
	if is_network_master():
		if armored or poison_death:
			return 
		if not civilian and body.get("player_spotted"):
			if not dart and (body.player_spotted or body.line_of_sight > 0):
				return 
		if dead:
			return 
		if body.has_method("set_tranquilized"):
			body.set_tranquilized()
			body.set_collision_layer_bit(4, false)

func interpolate(a, b, t):
	return (a * (1.0 - t)) + (b * t)
	
master func add_velocity(amount, normal):
	if is_network_master():
		if not armored:
			body.add_velocity(normal * amount)
	else:
		rpc_id(0,"add_velocity",amount, normal)

master func piercing_damage(damage, collision_n, collision_p):
	if is_network_master():
		if not dead and armor > 0:
			for body in new_alert_sphere.get_overlapping_bodies():
				if body.has_method("alert"):
					body.alert(glob.player.global_transform.origin)
			pain_sfx[0].play()
		armor -= damage
		if health <= flee_health and damage > 0.5:
			body.set_flee()
			flee = true
		if health <= 0:
			if not dead:
				die(damage, collision_n, collision_p)
		if health <= gib_health and not gibs_spawned and gib:
			gibs_spawned = true
			gib_sfx.play()
			for gib in len(GIBS):
				if head.get_head_health() > 0 and gib == G_HEAD:
					spawn_gib(gib, 1, damage, collision_n, collision_p)
					pass
				elif gib != G_HEAD:
					spawn_gib(gib, 1, damage, collision_n, collision_p)
					pass
			skeleton.hide()
			colliders.get_node("Dead_Head/CollisionShape").disabled = true
			colliders.get_node("Dead_Body/CollisionShape").disabled = true
			deathtimer.start()
	else:
		rpc_id(0,"piercing_damage",damage, collision_n, collision_p)

func alert_body_entered(b):
	if is_network_master():
		nearby.append(b)

func alert_body_exited(b):
	if is_network_master():
		nearby.remove(nearby.find(b))

master func damage(damage, collision_n, collision_p, shooter_pos):
	if is_network_master():
		if on_fire and not grilled_flag:
			if head_mesh:
				head_mesh.material_override = grilled_material
			if torso_mesh:
				torso_mesh.material_override = grilled_material
			grilled_flag = true
		if health > 199 and civilian:
			glob.player.UI.message("Stop that!", true)
		if armor > 0:
			if nodamage != null:
				nodamage.pitch_scale = 1.2 + rand_range(0, 0.2)
				nodamage.play()
			for body in new_alert_sphere.get_overlapping_bodies():
				if body.has_method("alert"):
					body.alert(glob.player.global_transform.origin)
			return 
		if not dead and damage > 0.5:
			if not alerted:
				for body in new_alert_sphere.get_overlapping_bodies():
					if body.has_method("alert"):
						body.alert(glob.player.global_transform.origin)
				alerted = true
			if not pain_sfx[0].playing:
				pain_sfx[0].play()
		if damage > 0.5:
			body.add_velocity(collision_n * damage * 0.2)
		health -= damage
		if health <= flee_health and damage > 0.5:
			body.set_flee()
			flee = true
		if health <= 0:
			if not dead:
				die(damage, collision_n, collision_p)
		if health <= gib_health and not gibs_spawned and gib and damage != 20.6:
			gibs_spawned = true
			gib_sfx.play()
			if rand_range(0, 1) < drop_chance:
				var i = 0
				for d in len(DROPS):
					if rand_range(0, 100) < DROP_CHANCE[i]:
						spawn_gib(d, 1, damage, collision_n, collision_p, "DROPS")
						pass
					i += 1
			for gib in len(GIBS):
				if head.get_head_health() > 0 and GIBS[gib] == G_HEAD:
					spawn_gib(gib, 1, damage, collision_n, collision_p)
					pass
				elif GIBS[gib] != G_HEAD:
					spawn_gib(gib, 1, damage, collision_n, collision_p)
					pass
			skeleton.hide()
			colliders.get_node("Dead_Head/CollisionShape").disabled = true
			colliders.get_node("Dead_Body/CollisionShape").disabled = true
			deathtimer.start()
	else:
		rpc_id(0,"damage",damage, collision_n, collision_p, shooter_pos)

func remove_objective():
	if dead:
		return 
	if objective:
		$Body / Objective_Indicator.hide()
		glob.remove_objective()
	if not civilian:
		glob.enemy_count -= 1
	else :
		glob.civ_count -= 1

master func spawn_gib(gib, count, damage, collision_n, collision_p, gibType = "GIBS", gibName = null):
	if is_network_master():
		if not gib:
			return

		for i_gib in range(count):
			randomize()
			var newGibName = int(rand_range(0,1000000))
			var new_gib = self[gibType][gib].instance()
			
			new_gib.set_name(new_gib.name + "#" + str(newGibName))
			
			new_gib.set_meta("syncData",{
				"assetPath": self[gibType][gib].resource_path,
				"syncProperties": [
					"global_transform"
				]
			})
			
			get_tree().get_nodes_in_group("Sync")[0].add_child(new_gib)
			
			new_gib.global_transform.origin = collision_p
			if "velocity" in new_gib:
				new_gib.velocity = (damage + rand_range(0, 10)) * - collision_n
			elif "body" in new_gib:
				new_gib.body.velocity = (damage + rand_range(0, 10)) * - collision_n
		
			rpc("_spawn_gib_client", gib, damage, collision_n, collision_p, gibType, newGibName)

master func remove_weapon():
	if is_network_master():
		if not civilian and "current_weapon" in weapon and not armored and health < 10000:
			if weapon.disabled:
				return 
			weapon.disabled = true
			var boneattachment = skeleton.get_node_or_null("Armature/Skeleton/BoneAttachment")
			if boneattachment:
				boneattachment.hide()
			var new_weapon_drop = weapon_drop.instance()
			get_parent().add_child(new_weapon_drop)
			new_weapon_drop.global_transform.origin = body.global_transform.origin + Vector3(0, 2, 0)
			new_weapon_drop.velocity = - (new_weapon_drop.global_transform.origin - glob.player.global_transform.origin).normalized() * 10
			new_weapon_drop.gun.MESH[new_weapon_drop.gun.current_weapon].hide()
			new_weapon_drop.gun.current_weapon = weapon.current_weapon
			new_weapon_drop.gun.ammo = weapon.MAX_MAG_AMMO[weapon.current_weapon]
			new_weapon_drop.gun.MESH[weapon.current_weapon].show()
	else:
		rpc_id(0,"remove_weapon")
	
func die(damage, collision_n, collision_p):
	if is_network_master():
		if not dead:
			if on_fire:
				pain_sfx[0].max_db = - 40
			if permadeath:
				glob.DEAD_CIVS.append(npc_name)
				glob.player.UI.notify(npc_name + " is dead.", Color(1, 0, 0))
				glob.save_game()
			
			if glob.implants.arm_implant.cursed_torch:
				if glob.player.health < 100:
					glob.player.health += 1
					glob.player.UI.set_health(glob.player.health)
			if heartbeat:
				heartbeat.hide()
			var boneattachment = skeleton.get_node_or_null("Armature/Skeleton/BoneAttachment")
			if boneattachment:
				boneattachment.hide()
			
			if not civilian and "current_weapon" in weapon:
				if "disabled" in weapon:
					if not weapon.disabled:
						var new_weapon_drop = weapon_drop.instance()
						get_parent().add_child(new_weapon_drop)
						new_weapon_drop.global_transform.origin = body.global_transform.origin + Vector3(0, 1, 0)
						new_weapon_drop.gun.MESH[new_weapon_drop.gun.current_weapon].hide()
						new_weapon_drop.gun.current_weapon = weapon.current_weapon
						new_weapon_drop.gun.ammo = weapon.MAX_MAG_AMMO[weapon.current_weapon]
						new_weapon_drop.gun.MESH[weapon.current_weapon].show()
			for particle in all_particles:
				particle.queue_free()
			body.set_dead()
			
			colliders.get_node("Head/CollisionShape").disabled = true
			colliders.get_node("Torso/CollisionShape").disabled = true
			colliders.get_node("Legs/CollisionShape").disabled = true
			if not poison_death:
				if not immortal and edible:
					dead_body.set_collision_layer_bit(8, 1)
				colliders.get_node("Dead_Body/CollisionShape").disabled = false
				colliders.get_node("Dead_Head/CollisionShape").disabled = false
			body.set_collision_layer_bit(4, false)
			dead = true
			if objective:
				$Body / Objective_Indicator.hide()
				glob.remove_objective()
			if not civilian:
				glob.enemy_count -= 1
			else :
				glob.civ_count -= 1
			if poison_death:
				poisontimer.start()
			if not civilian and not creature:
				glob.player.local_money += 10

func poison_timeout():
	if is_network_master():
		var new_misery = SELF_DESTRUCT.instance()
		add_child(new_misery)
		new_misery.global_transform.origin = body.global_transform.origin
		damage(500, Vector3.ZERO, body.global_transform.origin, Vector3.ZERO)

func align_up(node_basis, normal):
	var result = Basis()
	
	result.x = normal.cross(node_basis.y) + Vector3(1e-05, 0, 0)
	result.z = node_basis.x.cross(normal) + Vector3(0, 0, 1e-05)
	result = result.orthonormalized()
	
	result.z *= scale.z

	return result

func set_player_seen(sight):
	if objective:
		player_seen = sight

func grapple(pos3d:Position3D):
	if not dead:
		return 
	var point = glob.player.global_transform.origin
	var distance = body.global_transform.origin.distance_to(point)
	if distance > 3:
		body.velocity -= (body.global_transform.origin - point).normalized() * 22 * get_physics_process_delta_time()
