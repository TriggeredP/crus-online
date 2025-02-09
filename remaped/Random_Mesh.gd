extends Spatial

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var foodType = 0

onready var collision = get_node("../Area/CollisionShape")

func _ready():
	collision.disabled = true
	
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		if randi() % 2 != 0:
			foodType = randi() % get_child_count()
			get_child(foodType).show()
			collision.disabled = false
	else:
		get_food(null)

master func get_food(id):
	if not collision.disabled:
		NetworkBridge.n_rpc(self, "set_food", [foodType])

puppet func set_food(id, type):
	get_child(type).show()
	collision.disabled = false
