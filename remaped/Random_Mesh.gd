extends Spatial

var foodType = 0

onready var collision = get_node("../Area/CollisionShape")

func _ready():
	collision.disabled = true
	
	if get_tree().network_peer != null and is_network_master():
		if randi() % 2 != 0:
			foodType = randi() % get_child_count()
			get_child(foodType).show()
			collision.disabled = false
	else:
		get_food()

master func get_food():
	if not collision.disabled:
		rpc("set_food",foodType)

puppet func set_food(type):
	get_child(type).show()
	collision.disabled = false
