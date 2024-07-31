extends Spatial

export  var level_index = 13
export  var level_name = "Darkworld"

onready var Multiplayer = Global.get_node("Multiplayer")

func _ready():
	var new_mat = $level_painting / Cube.mesh.surface_get_material(1).duplicate()
	new_mat.albedo_texture = Global.LEVEL_IMAGES[level_index]
	$level_painting / Cube.set_surface_material(1, new_mat)

func _on_Area_body_entered(body):
	if body == Global.player:
		if is_network_master():
			if Global.BONUS_UNLOCK.find(level_name) == -1:
				Global.BONUS_UNLOCK.append(level_name)
				rpc("unlock_level")
			Global.save_game()
			Multiplayer.goto_scene_host(Global.LEVELS[level_index])
		else:
			Global.UI.notify("It's weird, it feels like a normal painting...", Color(1, 0, 0))

puppet func unlock_level():
	if Global.BONUS_UNLOCK.find(level_name) == -1:
		Global.BONUS_UNLOCK.append(level_name)
