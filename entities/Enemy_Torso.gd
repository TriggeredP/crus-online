extends KinematicBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var soul
export  var alive_head = false
export  var head = false
export  var poisonous = false
var headoff = false
var head_mesh
export  var gibbable = true
var boresound
var bored = false
export  var head_health = 40
var damage_multiplier = 1
var cancer_orb = preload("res://Cancerball.tscn")
var gibflag = false
var bloodparticles:Array = [preload("res://Entities/Particles/Blood_Particle.tscn"), preload("res://Entities/Particles/Blood_Particle3.tscn")]
onready var deadhead = get_node("../Dead_Head")

export  var type = 0

onready var head_gib = preload("res://Entities/Physics_Objects/Head_Gib.tscn")

# Multiplayer stuff
################################################################################

puppet func _spawn_gib_client(id, parentPath, collision_n, collision_p, gibName):
	var new_gib = head_gib.instance()
	new_gib.set_name(gibName)

	get_node(parentPath).add_child(new_gib)

puppet func _client_damage(id):
	for child in get_children():
		child.hide()
	hide()
	if is_instance_valid(head_mesh):
		head_mesh.hide()
	$CollisionShape.disabled = true
	gibflag = true

################################################################################

func _ready():
	NetworkBridge.register_rpcs(self,[
		["tranquilize", NetworkBridge.PERMISSION.ALL],
		["network_damage", NetworkBridge.PERMISSION.ALL],
		["_spawn_gib_client", NetworkBridge.PERMISSION.SERVER],
		["_client_damage", NetworkBridge.PERMISSION.SERVER]
	])
	
	set_physics_process(false)
	set_process(false)
	head_health = 50
	soul = get_parent().get_parent()
	if self.name == "Torso":
		damage_multiplier = 1
	elif head:
		head = true
		set_physics_process(true)
		head_mesh = get_parent().get_parent().get_node_or_null("Nemesis/Armature/Skeleton/Head_Mesh")
		damage_multiplier = 2
	elif self.name == "Legs":
		damage_multiplier = 0.5
	else :
		damage_multiplier = 1

func cancer():
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		if soul.cancer_immunity:
			return 
		if soul.armor > 0:
			return 
		for i in range(6):
			var cancerball = cancer_orb.instance()
			soul.get_parent().add_child(cancerball)
			cancerball.global_transform.origin = global_transform.origin
			cancerball.dir = cancerball.dir.rotated(Vector3.FORWARD, rand_range( - PI, PI))
			cancerball.dir = cancerball.dir.rotated(Vector3.LEFT, rand_range( - PI, PI))
			cancerball.dir = cancerball.dir.rotated(Vector3.UP, rand_range( - PI, PI))
		soul.remove_objective()
		soul.hide()

func _physics_process(delta):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		if bored:
			head_health -= 1
			damage(0, Vector3.ZERO, global_transform.origin, global_transform.origin)
			var new_blood_particle = bloodparticles[randi() % bloodparticles.size()].instance()
			add_child(new_blood_particle)
			new_blood_particle.global_transform.origin = global_transform.origin + Vector3.UP * 0.7
			new_blood_particle.rotation = Vector3(rand_range( - PI, PI), rand_range( - PI, PI), rand_range( - PI, PI))
			new_blood_particle.emitting = true

func set_water(a):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		if head:
			if soul.body.has_method("set_water") and not soul.body.dead:
				soul.body.set_water(a)

func add_velocity(normal, amount):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		soul.add_velocity(normal, amount)

master func tranquilize(id, dart):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		soul.set_tranquilized(dart)
	else:
		NetworkBridge.n_rpc_id(self, 0, "tranquilize", [dart])

func tranq_timeout(dart):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		soul.tranq_timeout(dart)

func grapple(pos:Position3D):
	soul.grapple(pos)

func damage(damage, collision_n, collision_p, shooter_pos):
	network_damage(null, damage, collision_n, collision_p, shooter_pos)

master func network_damage(id, damage, collision_n, collision_p, shooter_pos):
	if NetworkBridge.check_connection():
		if head and damage < 0.5 and not bored:
			return 
		soul.damage(damage * damage_multiplier, collision_n, collision_p, shooter_pos)
		if soul.armor <= 0:
			type = 0
		else :
			type = 1
		if head and not bored and damage > 0.5:
			head_health = - 1
		if bored and head_health > - 1 and NetworkBridge.n_is_network_master(self):
			head_health -= 1
		if head_health < 0 and headoff == false:
			if bored:
				if is_instance_valid(boresound):
					boresound.queue_free()
			bored = false
			deadhead.already_dead()
			soul.die(damage, collision_n, collision_p)
			if not gibflag and gibbable and NetworkBridge.n_is_network_master(self):
				var new_head_gib = head_gib.instance()
				new_head_gib.set_name(new_head_gib.name + "#" + str(new_head_gib.get_instance_id()))
				
				soul.add_child(new_head_gib)
				new_head_gib.global_transform.origin = global_transform.origin
				new_head_gib.damage(damage, collision_n, collision_p, shooter_pos)
				
				NetworkBridge.n_rpc(self, "_spawn_gib_client", [soul.get_path(), collision_n, collision_p, new_head_gib.name])
			for child in get_children():
				child.hide()
			hide()
			if is_instance_valid(head_mesh):
				head_mesh.hide()
			$CollisionShape.disabled = true
			gibflag = true
			if NetworkBridge.n_is_network_master(self):
				NetworkBridge.n_rpc(self, "_client_damage")
		if not NetworkBridge.n_is_network_master(self):
			NetworkBridge.n_rpc_id(self, 0, "network_damage", [damage, collision_n, collision_p, shooter_pos])

func player_use():
	if get_collision_layer_bit(8):
		if not soul.armored and Global.husk_mode:
			soul.damage(200, Vector3.ZERO, global_transform.origin, Vector3.ZERO)
			if not poisonous:
				Global.player.add_health(1)
				Global.player.UI.notify("Flesh consumed.", Color(1, 0, 0))
			else :
				Global.player.set_toxic()
		else :
			Global.player.weapon.hold(soul.body)

func remove_weapon():
	soul.remove_weapon()

func piercing_damage(damage, collision_n, collision_p, shooter_pos):
	if NetworkBridge.check_connection():
		soul.piercing_damage(damage * damage_multiplier, collision_n, collision_p)
		if head:
			head_health = - 1
		if head_health < 0 and headoff == false:
			deadhead.already_dead()
			soul.die(damage, collision_n, collision_p)
			if not gibflag and NetworkBridge.n_is_network_master(self):
				var new_head_gib = head_gib.instance()
				new_head_gib.set_name(new_head_gib.name + "#" + str(new_head_gib.get_instance_id()))
				soul.add_child(new_head_gib)
				
				new_head_gib.global_transform.origin = global_transform.origin
				new_head_gib.damage(damage, collision_n, collision_p, shooter_pos)
				
				NetworkBridge.n_rpc(self, "_spawn_gib_client", [soul.get_path(), collision_n, collision_p, new_head_gib.name])
			for child in get_children():
				child.hide()
			hide()
			if is_instance_valid(head_mesh):
				head_mesh.hide()
			$CollisionShape.disabled = true
			gibflag = true
			if NetworkBridge.n_is_network_master(self):
				NetworkBridge.n_rpc(self, "_client_damage")

func already_dead():
	headoff = true

func get_head_health():
	return head_health

func get_type():
	return type;
