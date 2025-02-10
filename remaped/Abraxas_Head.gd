extends KinematicBody

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var type = 1
var active = false
export  var health = 10
var destroyed = false

func _ready():
	NetworkBridge.register_rpcs(self, [
		["died", NetworkBridge.PERMISSION.SERVER],
		["network_damage", NetworkBridge.PERMISSION.ALL]
	])

puppet func died(id):
	get_parent().get_node("Sphere").hide()
	get_parent().get_node("Particle").show()

func damage(dmg, nrml, pos, shoot_pos):
	network_damage(null, dmg, nrml, pos, shoot_pos)

master func network_damage(id, dmg, nrml, pos, shoot_pos):
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		if not active:
			return 
		health -= dmg
		if health <= 0:
			destroyed = true
			died(null)
			NetworkBridge.n_rpc(self, "died")
	else:
		NetworkBridge.n_rpc(self, "network_damage", [dmg, nrml, pos, shoot_pos])

func get_type():
	return type
