extends KinematicBody

var type = 1
var active = false
export  var health = 10
var destroyed = false

func _ready():
	pass

puppet func died():
	get_parent().get_node("Sphere").hide()
	get_parent().get_node("Particle").show()

master func damage(dmg, nrml, pos, shoot_pos):
	if get_tree().network_peer != null and is_network_master():
		if not active:
			return 
		health -= dmg
		if health <= 0:
			destroyed = true
			died()
			rpc("died")
	else:
		rpc("damage", dmg, nrml, pos, shoot_pos)

func get_type():
	return type
