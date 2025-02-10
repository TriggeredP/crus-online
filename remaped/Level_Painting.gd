extends Spatial

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

export  var level_index = 13
export  var level_name = "Darkworld"

onready var Multiplayer = Global.get_node("Multiplayer")

func _ready():
	NetworkBridge.register_rpcs(self, [
		["unlock_level", NetworkBridge.PERMISSION.SERVER]
	])
	
	var new_mat = $level_painting / Cube.mesh.surface_get_material(1).duplicate()
	new_mat.albedo_texture = Global.LEVEL_IMAGES[level_index]
	$level_painting / Cube.set_surface_material(1, new_mat)

func _on_Area_body_entered(body):
	if body == Global.player:
		if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
			if Global.BONUS_UNLOCK.find(level_name) == -1:
				Global.BONUS_UNLOCK.append(level_name)
				NetworkBridge.n_rpc(self, "unlock_level")
			Global.save_game()
			Multiplayer.goto_scene_host(Global.LEVELS[level_index])
		else:
			Global.UI.notify("It feels like a normal painting", Color(1, 0, 0))

puppet func unlock_level(id):
	if Global.BONUS_UNLOCK.find(level_name) == -1:
		Global.BONUS_UNLOCK.append(level_name)
