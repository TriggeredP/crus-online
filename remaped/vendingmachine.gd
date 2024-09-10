extends StaticBody

var type = 1
var items = [preload("res://Entities/Physics_Objects/can1.tscn"), preload("res://Entities/Physics_Objects/chips1.tscn")]
var items_paths = ["res://Entities/Physics_Objects/can1.tscn", "res://Entities/Physics_Objects/chips1.tscn"]
var item_names = ["Hungry Human Soda", "Super Crunchers"]
export  var max_items = 10
var item_count = 0
var broken = false

puppet func _create_object(recivedPath, recivedObject, recivedName, recivedTransform):
	var newObject = load(recivedObject).instance()
	newObject.set_name(recivedName)
	get_node(recivedPath).add_child(newObject)
	newObject.global_transform = recivedTransform

func _ready():
	rset_config("item_count", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("broken", MultiplayerAPI.RPC_MODE_PUPPET)

master func activation(violence):
	if is_network_master():
		if broken:
			return 
		if item_count < max_items:
			item_count += 1
			rset("item_count", item_count)
			var rand = randi() % items.size()
			var new_item = items[rand].instance()
			new_item.set_name(new_item.name + "#" + str(randi() % 1000000000))
			add_child(new_item)
			new_item.global_transform.origin = $Position3D.global_transform.origin
			new_item.damage(10, (global_transform.origin - $Position3D.global_transform.origin).normalized(), global_transform.origin, global_transform.origin)
			
			rpc("_create_object", get_path(), items_paths[rand], new_item.name, new_item.global_transform)
			
			if not violence:
				rpc("notify", "Purchased " + str(item_names[rand]) + " for " + "$10", Color(0, 1, 1))
				Global.player.UI.notify("Purchased " + str(item_names[rand]) + " for " + "$10", Color(0, 1, 1))
	else:
		rpc("activation", violence)

func player_use():
	if Global.money < 10:
		Global.player.UI.notify("You don't have enough money.", Color(1, 0, 0))
		return 
	if broken:
		Global.player.UI.notify("It's broken.", Color(1, 0, 0))
		return 
	if item_count >= max_items:
		Global.player.UI.notify("It's empty.", Color(1, 0, 0))
		return 
	if Global.money >= 10:
		Global.money -= 10
		activation(false)

master func damage(a, n, p, sp):
	if is_network_master():
		if broken:
			return 
		if randi() % 3 == 0:
			broken = true
			rset("broken", true)
			$AudioStreamPlayer3D.playing = false
			rpc("stop_sound")
		activation(true)
	else:
		rpc("damage", a, n, p, sp)

puppet func stop_sound():
	$AudioStreamPlayer3D.playing = false

puppet func notify(value, color):
	Global.player.UI.notify(value, color)

func get_type():
	return type
